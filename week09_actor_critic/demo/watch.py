"""MuJoCo offscreen frames in a Matplotlib window with classroom controls."""
import os
os.environ.setdefault('MUJOCO_GL','egl')  # Choose before importing MuJoCo/Gymnasium.
import argparse
from pathlib import Path
import numpy as np
import torch
import gymnasium as gym
from algorithm import ENV_ID,TEST_SEEDS
from train import load_checkpoint


class Playback:
    def __init__(self,models):
        self.models=models
        self.controller='initial'
        self.episode=0;self.paused=True
        self.env=gym.make(ENV_ID,render_mode='rgb_array',width=720,height=480,
                          default_camera_config={'distance':4.0,'azimuth':90,'elevation':-15})
        self.reset()

    def reset(self):
        self.obs,_=self.env.reset(seed=TEST_SEEDS[self.episode])
        self.steps=0;self.total=0.;self.done=False;self.value=0.

    def select(self,name):
        if name not in self.models:raise ValueError('Unknown controller.')
        self.controller=name;self.reset()

    def next_episode(self):
        self.episode=(self.episode+1)%len(TEST_SEEDS);self.reset()

    def tick(self):
        if self.paused or self.done:return
        with torch.no_grad():
            x=torch.tensor(self.obs,dtype=torch.float32).unsqueeze(0)
            action=self.models[self.controller].deterministic(x)[0].numpy()
        self.obs,reward,term,trunc,_=self.env.step(action)
        self.steps+=1;self.total+=reward;self.done=term or trunc

    def current_value(self):
        with torch.no_grad():
            return float(self.models[self.controller].value(torch.tensor(self.obs,dtype=torch.float32).unsqueeze(0))[0])

    def close(self):self.env.close()


class Viewer:
    def __init__(self,initial,trained):
        import matplotlib.pyplot as plt
        from matplotlib.widgets import Button,RadioButtons
        self.plt=plt
        self.player=Playback({'initial':load_checkpoint(initial)[0],'trained':load_checkpoint(trained)[0]})
        self.fig,self.ax=plt.subplots(figsize=(10,7))
        self.fig.subplots_adjust(bottom=.22,top=.85)
        self.ax.axis('off');self.image=self.ax.imshow(self.player.env.render())
        self.title=self.fig.suptitle('')
        self.buttons=[]
        for x,label,fn in [(.08,'Play / Pause',self.toggle),(.31,'Restart',self.restart),(.54,'Next episode',self.next_episode)]:
            b=Button(self.fig.add_axes([x,.05,.19,.065]),label);b.on_clicked(fn);self.buttons.append(b)
        self.radio=RadioButtons(self.fig.add_axes([.77,.03,.19,.12]),['initial','trained'])
        self.radio.on_clicked(self.select)
        self.timer=self.fig.canvas.new_timer(interval=max(1,int(1000*self.player.env.unwrapped.dt)))
        self.timer.add_callback(self.tick);self.timer.start()
        self.fig.canvas.mpl_connect('close_event',self.close)
        self.render()

    def toggle(self,event=None):self.player.paused=not self.player.paused;self.render()
    def restart(self,event=None):self.player.reset();self.render()
    def next_episode(self,event=None):self.player.next_episode();self.render()
    def select(self,name):self.player.select(name);self.render()
    def tick(self):
        if not self.player.paused and not self.player.done:self.player.tick();self.render()
    def render(self):
        p=self.player
        self.image.set_data(p.env.render())
        self.title.set_text(f'{p.controller.upper()} | test {p.episode+1}/20 (seed {TEST_SEEDS[p.episode]}) | '+
            ('finished' if p.done else 'paused' if p.paused else 'running')+
            f'\nsteps={p.steps} | return={p.total:.0f} | angle={p.obs[1]:.3f} rad | critic V={p.current_value():.2f}')
        self.fig.canvas.draw_idle()
    def close(self,event=None):self.timer.stop();self.player.close()


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    classroom=Path(__file__).with_name('classroom')
    p.add_argument('--initial',type=Path,default=classroom/'initial.pt')
    p.add_argument('--trained',type=Path,default=classroom/'trained.pt')
    a=p.parse_args();torch.set_num_threads(1)
    try:
        viewer=Viewer(a.initial,a.trained);viewer.plt.show()
    except (ValueError,RuntimeError) as e:p.exit(1,str(e)+'\nUse saved classroom plots if rendering is unavailable.\n')
