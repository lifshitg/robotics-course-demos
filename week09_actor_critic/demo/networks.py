"""Separate actor and critic; bounded actions with consistent log densities."""
import math
import torch
from torch import nn
from torch.distributions import Normal
import torch.nn.functional as F


def mlp(output):
    net = nn.Sequential(nn.Linear(4,64),nn.Tanh(),nn.Linear(64,64),nn.Tanh(),nn.Linear(64,output))
    for layer in net:
        if isinstance(layer,nn.Linear):
            nn.init.orthogonal_(layer.weight, math.sqrt(2)); nn.init.zeros_(layer.bias)
    return net


class ActorCritic(nn.Module):
    def __init__(self):
        super().__init__()
        self.actor = mlp(1)
        self.critic = mlp(1)
        nn.init.orthogonal_(self.actor[-1].weight, .01)
        nn.init.orthogonal_(self.critic[-1].weight, 1.)
        self.log_std = nn.Parameter(torch.zeros(1))

    def distribution(self, obs):
        return Normal(self.actor(obs), self.log_std.clamp(-5,2).exp())

    def value(self,obs):
        return self.critic(obs).squeeze(-1)

    def log_probability(self,obs,latent):
        # a = 3*tanh(z). Stable log|da/dz|, including action scale.
        log_jacobian = math.log(3.) + 2*(math.log(2.)-latent-F.softplus(-2*latent))
        return (self.distribution(obs).log_prob(latent)-log_jacobian).sum(-1)

    def sample(self,obs):
        # sample(), not rsample(): retain the score-function gradient at a fixed action.
        latent = self.distribution(obs).sample()
        return 3*latent.tanh(), latent

    def deterministic(self,obs):
        return 3*self.actor(obs).tanh()
