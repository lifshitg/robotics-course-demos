# Week 10 — POMDPs: Beliefs, Bayesian Updates, and Information-Gathering Decisions

**38 minutes explanation/worked calculations + 4 minutes student exercise + 3 minutes questions/recap. No software-demo block.** 38 English slides: title, 30 teaching slides, one exercise, recap and five hidden backups. Preserve teaching notes, board-work README and existing SVG. The current conceptual sequence is expanded through annotated mathematics, original editable diagrams, and detailed notes. The selected schedule takes precedence over the preserved notes timing.

## Sequence and timing

| Physical slide | Topic | Minutes |
|---|---|---:|
| 1 | POMDPs: beliefs and decisions | 0 |
| 2 | What changes from an MDP? | 1.5 |
| 3 | State versus observation | 1 |
| 4 | The POMDP model | 1.5 |
| 5 | Fix the observation timing | 1 |
| 6 | Why history matters | 1 |
| 7 | What is a belief? | 1.5 |
| 8 | Belief space | 1 |
| 9 | Example A: move, then observe | 1 |
| 10 | Prediction by total probability | 1.5 |
| 11 | Prediction in matrix form | 1.5 |
| 12 | Read the observation model | 1 |
| 13 | Derive the Bayesian correction | 1.5 |
| 14 | Why normalize? | 1 |
| 15 | Red observation: complete calculation | 1.5 |
| 16 | Your turn: the blue alternative | 4 |
| 17 | Blue observation: answer and interpretation | 1 |
| 18 | The complete belief update | 1 |
| 19 | Check your update | 1 |
| 20 | An MDP over beliefs | 1 |
| 21 | Policies and rewards over beliefs | 1.5 |
| 22 | Bellman planning over beliefs | 2 |
| 23 | Example B: reset the problem | 1 |
| 24 | Immediate commitment | 1 |
| 25 | Sense and update | 1.5 |
| 26 | Calculate the value of information | 2 |
| 27 | When sensing is too expensive | 1 |
| 28 | A contingent policy tree | 1 |
| 29 | What does an alpha-vector store? | 1.5 |
| 30 | The commitment upper envelope | 1.5 |
| 31 | The sensing tree also has a vector | 1.5 |
| 32 | Why planning remains difficult | 1 |
| 33 | Questions & recap | 3 |
| 34 | Full conditioning and impossible evidence (hidden) | 0 |
| 35 | Matrix conventions and posterior odds (hidden) | 0 |
| 36 | General priors and sensing regions (hidden) | 0 |
| 37 | Policy-tree alpha-vector recursion (hidden) | 0 |
| 38 | A map of solution approaches (hidden) | 0 |

## Speaker guidance, formulas, and visuals

### 1. POMDPs: beliefs and decisions

Bayesian updates and the value of gathering information. Timing: 0 minutes. Visual: title. Existing professor reference: Class18-POMDPs.pdf printed slides 2–19.

Use 38 minutes of explanation/worked calculations, 4 minutes for the blue-observation exercise, and 3 minutes questions/recap. There is no executable software demo. The preserved teaching notes and board guide retain their existing timing; this deck and revised plan specify the selected schedule. Students know MDPs and planning from earlier weeks. Follow the existing sequence: partial observability, model/history/belief, prediction and correction, planning, information value, contingent policy trees and alpha-vectors. Examples A and B are TA-created and are separate problems. The professor PDF was not found locally; preserve printed-slide references without claiming review. Equations, matrices, diagrams and plots are editable. Five hidden backups provide deeper derivations.

- https://cdn.aaai.org/AAAI/1994/AAAI94-157.pdf
- https://www.pomdp.org/tutorial/pomdp-solving.html
- Local: TEACHING_NOTES.md, demo/README.md and visuals/commitment_values.svg. Examples A and B are TA-created.
- Existing reference: Class18-POMDPs.pdf, whose title page is documented as Class 17. Use printed slide numbers. PDF not found locally; not claimed as reviewed.

### 2. What changes from an MDP?

Uncertain motion and uncertain knowledge are different. Timing: 1.5 minutes. Visual: mdp. Existing professor reference: Class18-POMDPs.pdf printed slides 2.

An MDP can have stochastic transitions while revealing the resulting state. A POMDP has a hidden state and an observation process that supplies partial evidence. Explain this with a robot that may slip: if its final location is measured exactly, randomness in movement alone is still compatible with an MDP. If its sensor cannot distinguish locations, the agent must maintain uncertainty about state. A POMDP can also have deterministic motion and partial observations. The difference concerns what information is available to the decision maker, not whether the world is deterministic. We assume known transition and observation models for planning, rather than learning them in this session.

Stochastic motion alone does not make a model a POMDP.

- https://cdn.aaai.org/AAAI/1994/AAAI94-157.pdf
- https://www.pomdp.org/tutorial/pomdp-solving.html
- Local: TEACHING_NOTES.md, demo/README.md and visuals/commitment_values.svg. Examples A and B are TA-created.
- Existing reference: Class18-POMDPs.pdf, whose title page is documented as Class 17. Use printed slide numbers. PDF not found locally; not claimed as reviewed.

### 3. State versus observation

The physical situation is not the same as the sensor reading. Timing: 1 minutes. Visual: alias. Existing professor reference: Class18-POMDPs.pdf printed slides 3–5.

Use an original two-location diagram with both states pointing to a red sensor reading. The state is where the robot really is; the observation is evidence generated by its sensor. An observation can be noisy or simply ambiguous even when deterministic. It may be insufficient to distinguish states requiring different actions. Mention the existing qualitative wall-sensor reference on printed slide 5, but do not copy or reconstruct the unavailable professor illustration or infer numerical probabilities from it. Our later red/blue likelihoods are explicit TA-created numbers. The same observation need not imply the same posterior because priors and action histories can differ.

Two different locations can produce the same observation.

- https://cdn.aaai.org/AAAI/1994/AAAI94-157.pdf
- https://www.pomdp.org/tutorial/pomdp-solving.html
- Local: TEACHING_NOTES.md, demo/README.md and visuals/commitment_values.svg. Examples A and B are TA-created.
- Existing reference: Class18-POMDPs.pdf, whose title page is documented as Class 17. Use printed slide numbers. PDF not found locally; not claimed as reviewed.

### 4. The POMDP model

Specify dynamics, evidence, and consequences. Timing: 1.5 minutes. Visual: model. Existing professor reference: Class18-POMDPs.pdf printed slides 3, 10.

Define S as possible hidden states, A as actions, Tr as transition probabilities, R as expected immediate rewards, Omega as observation symbols, and O as observation likelihoods. The tuple uses the existing professor notation, not the Week 6 naming convention P for transition. Tr(s,a,s-prime) is a probability distribution over next states for each state/action. O(s-prime,a,o) is a distribution over observations given the resulting state and action. R(s,a) is the reward convention used in the belief reward formula; other formulations can specify transition-dependent rewards. We assume a known finite model. Horizon and discount determine the planning objective and are not additional sensor parameters. Explain symbols before arithmetic.

Planning horizon h and discount γ are specified separately.

- https://cdn.aaai.org/AAAI/1994/AAAI94-157.pdf
- https://www.pomdp.org/tutorial/pomdp-solving.html
- Local: TEACHING_NOTES.md, demo/README.md and visuals/commitment_values.svg. Examples A and B are TA-created.
- Existing reference: Class18-POMDPs.pdf, whose title page is documented as Class 17. Use printed slide numbers. PDF not found locally; not claimed as reviewed.

### 5. Fix the observation timing

Act first, transition, then receive evidence about the resulting state. Timing: 1 minutes. Visual: timing. Existing professor reference: Class18-POMDPs.pdf printed slides 3, 10.

Draw old state, chosen action, next state and emitted observation in that order. Uppercase S_t and A_t are random variables; lowercase s,a,s-prime denote their realizations. O is both the named observation model and, with a time subscript, the observation random variable; distinguish by context. Our observation model conditions on the post-action state. Other sources use different ordering/argument conventions, so check before combining formulas. The controller knows its chosen action and received observation, but not the realized hidden state. Reward R_t follows action A_t as in earlier sessions; this lesson writes the reward model R(s,a) separately from sensor observations.

- `Tr(s,a,s′) = P(S_{t+1}=s′ | S_t=s, A_t=a)`
- `O(s′,a,o) = P(O_{t+1}=o | S_{t+1}=s′, A_t=a)`

Use the resulting state s′ in the observation likelihood.

- https://cdn.aaai.org/AAAI/1994/AAAI94-157.pdf
- https://www.pomdp.org/tutorial/pomdp-solving.html
- Local: TEACHING_NOTES.md, demo/README.md and visuals/commitment_values.svg. Examples A and B are TA-created.
- Existing reference: Class18-POMDPs.pdf, whose title page is documented as Class 17. Use printed slide numbers. PDF not found locally; not claimed as reviewed.

### 6. Why history matters

The same latest reading can follow different histories. Timing: 1 minutes. Visual: history. Existing professor reference: Class18-POMDPs.pdf printed slides 6–9.

A latest reading is not generally a sufficient statistic. An earlier reliable sensor reading, followed by a known movement, can change which current location is plausible despite the same newest reading. Define history h_t to include prior information and actions/observations available before choosing action t. Under known Markov dynamics and the stated observation process, its relevant state information can be summarized by b_t. If rewards or other signals provide additional information about hidden state, include them in history and the observation model rather than discarding them. The deterministic reward/cost signals used before commitment in our examples add no extra hidden-state evidence. A belief policy can therefore avoid enumerating the entire raw history.

Belief summarizes relevant history under the assumed model.

- https://cdn.aaai.org/AAAI/1994/AAAI94-157.pdf
- https://www.pomdp.org/tutorial/pomdp-solving.html
- Local: TEACHING_NOTES.md, demo/README.md and visuals/commitment_values.svg. Examples A and B are TA-created.
- Existing reference: Class18-POMDPs.pdf, whose title page is documented as Class 17. Use printed slide numbers. PDF not found locally; not claimed as reviewed.

### 7. What is a belief?

A distribution over possible current states. Timing: 1.5 minutes. Visual: equations. Existing professor reference: Class18-POMDPs.pdf printed slides 8–9.

Belief is the posterior probability of each current state given available history. It is not the distribution of sensor readings, a sample of the robot pose, or the physical state itself. Nonnegative entries must sum to one. Choosing only the largest entry collapses uncertainty that matters when incorrect decisions are costly or sensing is possible. A belief of .6/.4 and .99/.01 have the same most likely state but substantially different confidence. A belief is model-dependent; it is not a claim of certainty about the real world. If model parameters are unknown, that introduces another estimation problem not solved merely by this fixed-model belief update.

- `b_t(s) = P(S_t=s | h_t)`
- `b_t(s) ≥ 0;    ∑_s b_t(s) = 1`
- `b = (0.6, 0.4) is not the same as “certainly L”.`

The most likely state alone discards decision-relevant uncertainty.

- https://cdn.aaai.org/AAAI/1994/AAAI94-157.pdf
- https://www.pomdp.org/tutorial/pomdp-solving.html
- Local: TEACHING_NOTES.md, demo/README.md and visuals/commitment_values.svg. Examples A and B are TA-created.
- Existing reference: Class18-POMDPs.pdf, whose title page is documented as Class 17. Use printed slide numbers. PDF not found locally; not claimed as reviewed.

### 8. Belief space

Two hidden states already allow infinitely many beliefs. Timing: 1 minutes. Visual: beliefLine. Existing professor reference: Class18-POMDPs.pdf printed slides 8–9, 15–19.

For two states, knowing p=b(L) fixes b(R)=1-p, so belief space is a continuous line from certainly R to certainly L. Mark .5/.5 and .6/.4 to show that the state set can be tiny while belief space is uncountable. For three states the nonnegative normalized vectors form a triangle; for m states an m-1 dimensional simplex. Do not spend class time on geometric derivations. The constraint removes one degree of freedom. A belief point describes knowledge about the possible physical states; it should not be confused with a workspace coordinate or configuration-space point from earlier weeks. This continuous space motivates special value representations later.

- `b = (p, 1−p),    0 ≤ p ≤ 1`
- `m states: ∑_i b_i = 1 gives an (m−1)-dimensional simplex.`

A point in belief space represents uncertainty, not a physical location.

- https://cdn.aaai.org/AAAI/1994/AAAI94-157.pdf
- https://www.pomdp.org/tutorial/pomdp-solving.html
- Local: TEACHING_NOTES.md, demo/README.md and visuals/commitment_values.svg. Examples A and B are TA-created.
- Existing reference: Class18-POMDPs.pdf, whose title page is documented as Class 17. Use printed slide numbers. PDF not found locally; not claimed as reviewed.

### 9. Example A: move, then observe

TA-created model · prior b = (0.6, 0.4) in (L,R) order. Timing: 1 minutes. Visual: exampleA. Existing professor reference: Class18-POMDPs.pdf printed slides 10.

Keep Example A initial belief .6/.4 visible. Move transitions: from L, .8 to L and .2 to R; from R, .1 to L and .9 to R. Sensor: resulting L emits red .9 or blue .1; resulting R emits red .2 or blue .8. Every transition row and every sensor row sums to one. The agent observes the action and sensor symbol rather than the realized state transition. The sensor table is separate from the transition table. Predict after moving before using the likelihood. Red and blue will be alternative observations from this same predicted belief, not consecutive readings in one episode. All numbers come from the existing TA notes rather than the professor wall diagram.

Transition rows: old state. Columns: resulting state.

- https://cdn.aaai.org/AAAI/1994/AAAI94-157.pdf
- https://www.pomdp.org/tutorial/pomdp-solving.html
- Local: TEACHING_NOTES.md, demo/README.md and visuals/commitment_values.svg. Examples A and B are TA-created.
- Existing reference: Class18-POMDPs.pdf, whose title page is documented as Class 17. Use printed slide numbers. PDF not found locally; not claimed as reviewed.

### 10. Prediction by total probability

Average over the unknown old state. Timing: 1.5 minutes. Visual: equations. Existing professor reference: Class18-POMDPs.pdf printed slides 10.

Derive by conditioning on each possible old state. To be at resulting L, the robot could have started in L and remained there or started in R and moved there. Weight each possibility by the old belief, then sum. This is the law of total probability, not a maximum over possible transitions. The .52/.48 prediction sums to one because the transition model is row-stochastic. Explain the bar as predicted belief before the observation, not an average policy value. If the relevant transition were identity, prediction would equal the prior; move is not identity here. Prediction may increase or decrease uncertainty depending on dynamics and prior. It is not evidence correction yet.

- `b̄(s′) = ∑_s Tr(s,a,s′) b(s)`
- `b̄(L) = 0.8 × 0.6 + 0.1 × 0.4 = 0.52`
- `b̄(R) = 0.2 × 0.6 + 0.9 × 0.4 = 0.48`

Prediction uses the action model, before the new observation.

- https://cdn.aaai.org/AAAI/1994/AAAI94-157.pdf
- https://www.pomdp.org/tutorial/pomdp-solving.html
- Local: TEACHING_NOTES.md, demo/README.md and visuals/commitment_values.svg. Examples A and B are TA-created.
- Existing reference: Class18-POMDPs.pdf, whose title page is documented as Class 17. Use printed slide numbers. PDF not found locally; not claimed as reviewed.

### 11. Prediction in matrix form

Column beliefs and row-stochastic transitions require a transpose. Timing: 1.5 minutes. Visual: predictionMatrix. Existing professor reference: Class18-POMDPs.pdf printed slides 10.

Use T_a with old states as rows and new states as columns, and represent belief as a column. Multiplying T_a transpose by b therefore sums over each old-state row for a fixed destination. Write the exact transposed matrix [.8,.1;.2,.9] times [.6;.4] to obtain [.52;.48]. A row-vector convention would instead write b transpose times T_a; do not mix conventions. No transpose is needed in the scalar summation because its indices state the direction explicitly. Test identity dynamics, row normalization and preservation of belief mass. Define the superscript T as matrix transpose, not a time index or planning horizon. Matrices on the slide are editable.

Each destination collects probability mass from all old states.

- https://cdn.aaai.org/AAAI/1994/AAAI94-157.pdf
- https://www.pomdp.org/tutorial/pomdp-solving.html
- Local: TEACHING_NOTES.md, demo/README.md and visuals/commitment_values.svg. Examples A and B are TA-created.
- Existing reference: Class18-POMDPs.pdf, whose title page is documented as Class 17. Use printed slide numbers. PDF not found locally; not claimed as reviewed.

### 12. Read the observation model

A likelihood answers: how likely is this reading in this state? Timing: 1 minutes. Visual: sensor. Existing professor reference: Class18-POMDPs.pdf printed slides 10.

Read .9 as the probability of red given resulting L and the selected action, not a .9 posterior for L after red. The model rows sum across red/blue for each state/action. The red likelihood column .9/.2 need not sum to one because its entries condition on different states. Bayes combines likelihood with predicted prior mass. Compare the same red sensor likelihood under a strongly R-biased prior versus a strongly L-biased prior; the posterior differs. An uninformative likelihood equal across states leaves the predicted belief unchanged after normalization. A perfect discriminatory reading can concentrate belief if that reading has positive prior probability. Distinguish sensor reliability from posterior confidence.

P(red | L) is not P(L | red).

- https://cdn.aaai.org/AAAI/1994/AAAI94-157.pdf
- https://www.pomdp.org/tutorial/pomdp-solving.html
- Local: TEACHING_NOTES.md, demo/README.md and visuals/commitment_values.svg. Examples A and B are TA-created.
- Existing reference: Class18-POMDPs.pdf, whose title page is documented as Class 17. Use printed slide numbers. PDF not found locally; not claimed as reviewed.

### 13. Derive the Bayesian correction

Conditional probability combines prediction with sensor evidence. Timing: 1.5 minutes. Visual: equations. Existing professor reference: Class18-POMDPs.pdf printed slides 10.

Start from conditional probability: joint probability of resulting state and observation divided by probability of the observation. Factor the joint into observation likelihood given state/action times probability of the resulting state given belief/action. Conditional independence in the model makes the likelihood depend on resulting state and action rather than the entire past history. The second factor is the prediction we already calculated. The normalizer accounts for all possible resulting states that could emit the observed symbol. Superscript ao labels the action/observation-conditioned belief rather than exponentiation. Keep the evidence order explicit. The hidden state does not become observed simply because we now have a posterior.

- `b^{ao}(s′) = P(s′ | b,a,o)`
- `                 = P(o,s′ | b,a) / P(o | b,a)`
- `                 = O(s′,a,o) b̄(s′) / P(o | b,a)`

Likelihood × predicted probability, divided by observation probability.

- https://cdn.aaai.org/AAAI/1994/AAAI94-157.pdf
- https://www.pomdp.org/tutorial/pomdp-solving.html
- Local: TEACHING_NOTES.md, demo/README.md and visuals/commitment_values.svg. Examples A and B are TA-created.
- Existing reference: Class18-POMDPs.pdf, whose title page is documented as Class 17. Use printed slide numbers. PDF not found locally; not claimed as reviewed.

### 14. Why normalize?

Weights are joint probabilities, not yet a posterior distribution. Timing: 1 minutes. Visual: equations. Existing professor reference: Class18-POMDPs.pdf printed slides 10.

The weight is the joint probability mass of a resulting state and the observed symbol given the prior/action. Its sum is the observation probability. Dividing each weight by this common sum makes posterior entries sum to one while preserving relative likelihood-weighted odds. If Z=0, the model says this observation cannot occur from the current belief/action. Do not divide by zero or silently invent a uniform posterior. In a real system this could indicate model mismatch or numerical issues needing an explicitly designed handling policy, outside this teaching calculation. If a state has zero predicted probability, finite likelihood cannot restore it by this correction alone; transition prediction can move mass into it.

- `w(s′) = O(s′,a,o) b̄(s′)`
- `Z = P(o | b,a) = ∑_{s′} w(s′)`
- `b^{ao}(s′) = w(s′) / Z,    for Z > 0`

Z = 0: the conditional posterior is undefined under the model.

- https://cdn.aaai.org/AAAI/1994/AAAI94-157.pdf
- https://www.pomdp.org/tutorial/pomdp-solving.html
- Local: TEACHING_NOTES.md, demo/README.md and visuals/commitment_values.svg. Examples A and B are TA-created.
- Existing reference: Class18-POMDPs.pdf, whose title page is documented as Class 17. Use printed slide numbers. PDF not found locally; not claimed as reviewed.

### 15. Red observation: complete calculation

Start from the prediction (0.52, 0.48), not the original prior. Timing: 1.5 minutes. Visual: posteriorRed. Existing professor reference: Class18-POMDPs.pdf printed slides 10.

Multiply red likelihood .9 by predicted L mass .52 to obtain .468. Multiply .2 by predicted R mass .48 to obtain .096. Observation probability is .564. Divide to get L .8297872340 and R .1702127660. Check nonnegativity and sum one. Explain that red is more compatible with L, while the remaining R probability reflects the possibility of red in R. The observation likelihood column .9/.2 is not the posterior. The original .6/.4 prior is not used directly after a nonidentity move. Keep the three stages visually separate: prediction, weighting, normalization. Ask students to predict the direction of the update before revealing exact values.

Red favors L, but does not make L certain.

- https://cdn.aaai.org/AAAI/1994/AAAI94-157.pdf
- https://www.pomdp.org/tutorial/pomdp-solving.html
- Local: TEACHING_NOTES.md, demo/README.md and visuals/commitment_values.svg. Examples A and B are TA-created.
- Existing reference: Class18-POMDPs.pdf, whose title page is documented as Class 17. Use printed slide numbers. PDF not found locally; not claimed as reviewed.

### 16. Your turn: the blue alternative

Four minutes · use the SAME prediction b̄ = (0.52, 0.48). Timing: 4 minutes. Visual: exercise. Existing professor reference: Class18-POMDPs.pdf printed slides 10.

Give four minutes for individual or pair work. Display only the prediction and blue likelihoods .1/.8, with blank weight/normalizer/posterior entries. Do not show red posterior as the new prior. Prompts: which state should blue favor; what is the probability of blue; do your final entries sum to one? Check transition direction and arithmetic if students struggle. Answer is on the next slide, not the visible exercise: weights .052/.384; Z=.436; posterior .1192660550/.8807339450. These are alternative observations after the same move, not two successive sensor updates. Speaker notes and PDF include the answer for instructor review. No homework problem is invented.

Find the weights, observation probability, and normalized belief.

- https://cdn.aaai.org/AAAI/1994/AAAI94-157.pdf
- https://www.pomdp.org/tutorial/pomdp-solving.html
- Local: TEACHING_NOTES.md, demo/README.md and visuals/commitment_values.svg. Examples A and B are TA-created.
- Existing reference: Class18-POMDPs.pdf, whose title page is documented as Class 17. Use printed slide numbers. PDF not found locally; not claimed as reviewed.

### 17. Blue observation: answer and interpretation

A different observation leads to a different posterior. Timing: 1 minutes. Visual: posteriorBlue. Existing professor reference: Class18-POMDPs.pdf printed slides 10.

Reveal .1 times .52=.052 and .8 times .48=.384. The blue observation probability is .436. Divide to obtain .1192660550 for L and .8807339450 for R. The posterior favors R because blue is much more likely there. Both this posterior and the red one are calculated from .52/.48, and the observation probabilities .564 and .436 sum to one. Common mistakes: using the red posterior, forgetting the move, normalizing .1/.8 alone, or exchanging transition rows and columns. Compare student results before moving on. A posterior probability represents model-conditioned uncertainty, not a new physical state or a sensor accuracy parameter.

Blue and red are alternatives, not consecutive corrections.

- https://cdn.aaai.org/AAAI/1994/AAAI94-157.pdf
- https://www.pomdp.org/tutorial/pomdp-solving.html
- Local: TEACHING_NOTES.md, demo/README.md and visuals/commitment_values.svg. Examples A and B are TA-created.
- Existing reference: Class18-POMDPs.pdf, whose title page is documented as Class 17. Use printed slide numbers. PDF not found locally; not claimed as reviewed.

### 18. The complete belief update

Prediction and correction form one recursive estimator. Timing: 1 minutes. Visual: equations. Existing professor reference: Class18-POMDPs.pdf printed slides 10.

The full numerator combines movement prediction and observation weighting. The denominator sums this joint mass over all resulting states. x is a dummy destination index; it is different from the old-state summation s. In the matrix form, D_a,o has observation likelihoods on the diagonal. For red its diagonal is .9/.2; for blue .1/.8. One transpose symbol denotes the matrix operation. Vector 1 contains ones so its transposed dot product sums weights. The formulation assumes the post-action observation convention and column beliefs. All formulas agree with the step-by-step calculations. This estimator is recursive: the new posterior becomes the next prior if we continue the same problem, but Example B will deliberately reset.

- `b^{ao}(s′) = [ O(s′,a,o) ∑_s Tr(s,a,s′)b(s) ] / Z`
- `Z = ∑_x O(x,a,o) ∑_s Tr(s,a,x)b(s)`
- `b̄ = T_a^T b;    w = D_{a,o} b̄;    b^{ao} = w / (1^T w)`

D is diagonal: one likelihood per resulting state.

- https://cdn.aaai.org/AAAI/1994/AAAI94-157.pdf
- https://www.pomdp.org/tutorial/pomdp-solving.html
- Local: TEACHING_NOTES.md, demo/README.md and visuals/commitment_values.svg. Examples A and B are TA-created.
- Existing reference: Class18-POMDPs.pdf, whose title page is documented as Class 17. Use printed slide numbers. PDF not found locally; not claimed as reviewed.

### 19. Check your update

Before planning, validate the probability calculation. Timing: 1 minutes. Visual: equations. Existing professor reference: Class18-POMDPs.pdf printed slides 10.

The posterior averaging identity is the law of total probability: before knowing which observation will arrive, averaging the conditional posteriors with their observation probabilities recovers the prediction. Use full-precision values for verification; rounded numbers cause tiny differences. This does not imply each individual posterior equals the prediction. Along with model row sums, belief normalization, and expected qualitative direction, it is a strong arithmetic check. Observations can be surprising and need not always reduce uncertainty in an individual realization. Informative sensors reduce suitable uncertainty measures in expectation under the model, but avoid presenting monotonic per-observation confidence as a rule. Zero-probability observation branches need not be assigned a fabricated posterior.

- `∑_o P(o | b,a) = 0.564 + 0.436 = 1`
- `∑_o P(o | b,a) b^{ao}(s′) = b̄(s′)`
- `0.564 × 0.829787 + 0.436 × 0.119266 ≈ 0.52`

Average the possible posteriors: recover the predicted belief.

- https://cdn.aaai.org/AAAI/1994/AAAI94-157.pdf
- https://www.pomdp.org/tutorial/pomdp-solving.html
- Local: TEACHING_NOTES.md, demo/README.md and visuals/commitment_values.svg. Examples A and B are TA-created.
- Existing reference: Class18-POMDPs.pdf, whose title page is documented as Class 17. Use printed slide numbers. PDF not found locally; not claimed as reviewed.

### 20. An MDP over beliefs

The belief is observed by the agent; the physical state stays hidden. Timing: 1 minutes. Visual: beliefMDP. Existing professor reference: Class18-POMDPs.pdf printed slides 11–12.

The controller knows the distribution it computed even though it does not know the actual state. For a current belief/action, each possible observation determines a next belief through the update. Before the observation arrives, these branches are random with probabilities P(o|b,a). Thus the belief process is Markov under the known model and sufficient history convention. This is a fully observed continuous-state belief MDP, not a claim that hidden-state uncertainty disappears. Multiple observations can map to the same posterior; their probabilities add if defining a belief transition kernel. Filtering computes the distribution; planning chooses which action to take from it. Even the two-state case has infinitely many possible beliefs.

Given b, a and o, the next belief is determined.

- https://cdn.aaai.org/AAAI/1994/AAAI94-157.pdf
- https://www.pomdp.org/tutorial/pomdp-solving.html
- Local: TEACHING_NOTES.md, demo/README.md and visuals/commitment_values.svg. Examples A and B are TA-created.
- Existing reference: Class18-POMDPs.pdf, whose title page is documented as Class 17. Use printed slide numbers. PDF not found locally; not claimed as reviewed.

### 21. Policies and rewards over beliefs

Choose using uncertainty, not only the most likely state. Timing: 1.5 minutes. Visual: equations. Existing professor reference: Class18-POMDPs.pdf printed slides 11–12.

A deterministic finite-horizon policy maps belief and remaining decisions to an action. A stochastic policy could instead specify an action distribution; the optimality equation below uses a maximizing action. R(b,a) is the expected immediate reward under hidden-state belief. The robot still receives reward generated by the actual hidden state/action; it does not receive reward merely for believing it is somewhere beneficial. The illustrative commitment calculation uses the reward vector from Example B but is not a continuation of Example A or a change in its model. Greater uncertainty can justify sensing even with the same most likely state. Keep horizon h distinct from time-indexed raw history h_t.

- `a = π_h(b): policy for h decisions remaining`
- `R(b,a) = ∑_s b(s) R(s,a)`
- `Example: b = (0.6,0.4), commit L → 0.6(10)+0.4(−10)=2`

Expected reward averages over the possible hidden states.

- https://cdn.aaai.org/AAAI/1994/AAAI94-157.pdf
- https://www.pomdp.org/tutorial/pomdp-solving.html
- Local: TEACHING_NOTES.md, demo/README.md and visuals/commitment_values.svg. Examples A and B are TA-created.
- Existing reference: Class18-POMDPs.pdf, whose title page is documented as Class 17. Use printed slide numbers. PDF not found locally; not claimed as reviewed.

### 22. Bellman planning over beliefs

Choose an action, then average the possible observation branches. Timing: 2 minutes. Visual: bellman. Existing professor reference: Class18-POMDPs.pdf printed slides 11–12.

Define V_h as the optimal expected discounted sum with h decisions remaining; V_0 is zero because no decisions remain. The immediate expected reward is added to discounted future value. For each action, average future values over possible observations, updating belief separately on each branch. Only after computing this expectation do we maximize over actions. Never maximize over the favorable observation or pretend we can choose the true hidden state. The future V includes its own optimal action choice, which can differ by observation. Terminal commitment has no future value; it can be represented through a terminal state convention. With gamma=1 a finite horizon is still well-defined. Zero-probability branches contribute zero and do not require evaluating undefined posteriors. This is planning with a known model, not an RL training update.

- `V_0(b) = 0`
- `V_h(b) = max_a [ R(b,a)`
- `               + γ ∑_o P(o | b,a) V_{h−1}(b^{ao}) ]`

Maximum: action choice. Sum: uncertain observations. Update: future belief.

- https://cdn.aaai.org/AAAI/1994/AAAI94-157.pdf
- https://www.pomdp.org/tutorial/pomdp-solving.html
- Local: TEACHING_NOTES.md, demo/README.md and visuals/commitment_values.svg. Examples A and B are TA-created.
- Existing reference: Class18-POMDPs.pdf, whose title page is documented as Class 17. Use printed slide numbers. PDF not found locally; not claimed as reviewed.

### 23. Example B: reset the problem

NEW question · prior b = (0.5,0.5) · no move before sensing. Timing: 1 minutes. Visual: exampleB. Existing professor reference: Class18-POMDPs.pdf printed slides 5, 11–12.

Explicitly reset rather than carrying over either Example A posterior. Sense leaves the physical state unchanged, so its transition matrix is identity, and uses the same red/blue sensor model. Commit L pays +10 in L and -10 in R; commit R reverses those rewards. Both end the task. Sense costs1 and then permits one commitment selected after its observation. There are at most two decisions, with no discounting, so gamma1 does not mean an undiscounted infinite-horizon claim. The information action is useful only through later decisions. The robot has no opportunity to move between locations or sense indefinitely in this specified question. Use a different visual example label to prevent accidental prior reuse.

Finite choice: commit now, or sense once and then commit. γ = 1.

- https://cdn.aaai.org/AAAI/1994/AAAI94-157.pdf
- https://www.pomdp.org/tutorial/pomdp-solving.html
- Local: TEACHING_NOTES.md, demo/README.md and visuals/commitment_values.svg. Examples A and B are TA-created.
- Existing reference: Class18-POMDPs.pdf, whose title page is documented as Class 17. Use printed slide numbers. PDF not found locally; not claimed as reviewed.

### 24. Immediate commitment

Without additional evidence, both choices tie at the uniform prior. Timing: 1 minutes. Visual: equations. Existing professor reference: Class18-POMDPs.pdf printed slides 11–12.

We average the outcome reward across the hidden state because the controller does not know which is true. Uniform belief yields zero expected reward for either commitment. That does not mean the realized reward is zero: the actual terminal outcome is either plus10 or minus10. Expected value is different from a worst-case guarantee. With a different prior the preferred commitment can change. Immediate commitment involves one decision; the sense strategy includes a cost and one later commitment. The comparison is between allowed strategies in this finite problem, not an artificial equalization of decision counts. The next slides compute whether the extra information outweighs its cost.

- `V_L = 0.5 × 10 + 0.5 × (−10) = 0`
- `V_R = 0.5 × (−10) + 0.5 × 10 = 0`
- `V_{commit} = max(0,0) = 0`

Reach a decision now; the task then ends.

- https://cdn.aaai.org/AAAI/1994/AAAI94-157.pdf
- https://www.pomdp.org/tutorial/pomdp-solving.html
- Local: TEACHING_NOTES.md, demo/README.md and visuals/commitment_values.svg. Examples A and B are TA-created.
- Existing reference: Class18-POMDPs.pdf, whose title page is documented as Class 17. Use printed slide numbers. PDF not found locally; not claimed as reviewed.

### 25. Sense and update

Identity transition: prediction equals the new uniform prior. Timing: 1.5 minutes. Visual: senseResults. Existing professor reference: Class18-POMDPs.pdf printed slides 10–12.

Because sensing does not move the robot, prediction stays .5/.5. Red weights .45/.10 sum to .55; normalized posterior is9/11 and2/11. Blue weights .05/.40 sum to .45; posterior is1/9 and8/9. After red, commit L gives conditional expectation70/11; after blue, commit R gives70/9. The observation probabilities weight those conditional decision values when computing the pre-observation expected value. Do not substitute Example A probabilities .564/.436 here. Show the prior visibly on the slide and map each posterior to its chosen commitment. Bayes changes knowledge rather than physically moving the robot. Both branches preserve uncertainty, even though the preferred decision becomes clear.

After red choose L; after blue choose R.

- https://cdn.aaai.org/AAAI/1994/AAAI94-157.pdf
- https://www.pomdp.org/tutorial/pomdp-solving.html
- Local: TEACHING_NOTES.md, demo/README.md and visuals/commitment_values.svg. Examples A and B are TA-created.
- Existing reference: Class18-POMDPs.pdf, whose title page is documented as Class 17. Use printed slide numbers. PDF not found locally; not claimed as reviewed.

### 26. Calculate the value of information

Pay once, then choose the commitment using the observation. Timing: 2 minutes. Visual: equations. Existing professor reference: Class18-POMDPs.pdf printed slides 5, 11–12.

Take the expectation before sensing: sensing cost minus1 is certain; red probability .55 multiplies its conditional best commitment value; blue probability .45 multiplies its own conditional value. Each branch contributes3.5, giving6. Independently condition on the true state: in L, red makes the policy correct with probability .9; in R, blue makes it correct with probability .8. Averaging with uniform prior gives .85 correctness. Expected commitment reward is7, then subtract cost1. This policy is not a guarantee of correct commitment; it still errs15 percent of the time. The value arises from choosing different actions after evidence. No physical-state change is required for an action to have useful future value.

- `V_{sense} = −1 + 0.55(70/11) + 0.45(70/9)`
- `= −1 + 3.5 + 3.5 = 6`
- `P(correct) = 0.5(0.9) + 0.5(0.8) = 0.85`
- `Check: 0.85(10) + 0.15(−10) − 1 = 6`

Information is valuable because it changes the later decision.

- https://cdn.aaai.org/AAAI/1994/AAAI94-157.pdf
- https://www.pomdp.org/tutorial/pomdp-solving.html
- Local: TEACHING_NOTES.md, demo/README.md and visuals/commitment_values.svg. Examples A and B are TA-created.
- Existing reference: Class18-POMDPs.pdf, whose title page is documented as Class 17. Use printed slide numbers. PDF not found locally; not claimed as reviewed.

### 27. When sensing is too expensive

Useful information is not automatically worth its cost. Timing: 1 minutes. Visual: equations. Existing professor reference: Class18-POMDPs.pdf printed slides 5, 11–12.

The gross expected commitment improvement is7 at this uniform prior. The value after cost c is7-c, compared with zero for immediate commitment. Thus sensing beats immediate commitment only below cost7. At cost8 its expected value is minus1. These are not universal sensing-cost thresholds. A different prior or sensor changes the information benefit; at high confidence the new observation may not change the best decision and a positive sensing cost can be wasted. Reward stakes also affect how much improved correctness is worth. This is expected-return optimization, not risk-sensitive or guaranteed-safe decision making. If future rewards were discounted, the commitment benefit would be discounted too; this finite example uses gamma1.

- `At b = (0.5,0.5):    V_{sense}(c) = 7 − c`
- `c < 7: sense wins;    c = 7: tie`
- `c = 8: V_{sense} = −1 < V_{commit} = 0`

This threshold depends on the prior, sensor, rewards, and horizon.

- https://cdn.aaai.org/AAAI/1994/AAAI94-157.pdf
- https://www.pomdp.org/tutorial/pomdp-solving.html
- Local: TEACHING_NOTES.md, demo/README.md and visuals/commitment_values.svg. Examples A and B are TA-created.
- Existing reference: Class18-POMDPs.pdf, whose title page is documented as Class 17. Use printed slide numbers. PDF not found locally; not claimed as reviewed.

### 28. A contingent policy tree

The action after sensing depends on what was observed. Timing: 1 minutes. Visual: tree. Existing professor reference: Class18-POMDPs.pdf printed slides 13–14.

Draw sense at the root, with red and blue observation branches leading to commit L and commit R. Show observation probabilities .55/.45 only for the uniform root belief; those branch probabilities would change with another prior. A policy tree prescribes actions for observations that have not yet happened. It is not one fixed action sequence and does not let us select the observation branch. Terminal commitment leaves end the task. The belief after each branch explains why its action is chosen. A fixed tree can be evaluated separately in each possible hidden start state, yielding an alpha-vector. This bridge connects contingent decisions to compact value representation without implementing a solver.

Actions are nodes; observations label the branches.

- https://cdn.aaai.org/AAAI/1994/AAAI94-157.pdf
- https://www.pomdp.org/tutorial/pomdp-solving.html
- Local: TEACHING_NOTES.md, demo/README.md and visuals/commitment_values.svg. Examples A and B are TA-created.
- Existing reference: Class18-POMDPs.pdf, whose title page is documented as Class 17. Use printed slide numbers. PDF not found locally; not claimed as reviewed.

### 29. What does an alpha-vector store?

One fixed decision or tree, evaluated in each possible hidden state. Timing: 1.5 minutes. Visual: equations. Existing professor reference: Class18-POMDPs.pdf printed slides 15–19.

An alpha-vector has one entry per hidden state, but entries are returns and may be negative or need not sum to one. For an immediate commitment, the entries are the terminal rewards at L and R. For a multi-step fixed tree they are expected returns including transition/observation probabilities and prescribed branch actions. Once a tree is fixed, expectation over the unknown start state is linear in the belief. Alpha is a value-vector label, not the learning-rate symbol used in earlier RL lessons. The agent can compare dot products for several available trees and choose the tree giving the largest value at its belief. This representation does not claim a single vector captures the optimal policy for all beliefs.

- `α_L = (10,−10);    α_R = (−10,10)`
- `V_{fixed}(b) = b^T α = ∑_s b(s)α(s)`
- `α(s): expected return of that fixed policy when starting in s`

The vector stores values; it is not a belief distribution.

- https://cdn.aaai.org/AAAI/1994/AAAI94-157.pdf
- https://www.pomdp.org/tutorial/pomdp-solving.html
- Local: TEACHING_NOTES.md, demo/README.md and visuals/commitment_values.svg. Examples A and B are TA-created.
- Existing reference: Class18-POMDPs.pdf, whose title page is documented as Class 17. Use printed slide numbers. PDF not found locally; not claimed as reviewed.

### 30. The commitment upper envelope

Only the two immediate commitments are included in this plot. Timing: 1.5 minutes. Visual: commitPlot. Existing professor reference: Class18-POMDPs.pdf printed slides 15–19.

Let p=b(L). Dot products give commit L value10p-10(1-p)=20p-10 and commit R value-10p+10(1-p)=10-20p. They intersect atp=.5 with value0. The upper envelope is the maximum: choose R below .5, L above .5, and either at the tie. It is piecewise linear and convex in belief under reward maximization. Preserve the existing SVG, which excludes sensing, and recreate the same mathematical lines as editable shapes in this deck. Do not call this the full two-decision sensing value function. Its value zero at the uniform belief and sensing value6 refer to different allowed strategies. The separate next plot adds the fixed sensing tree.

Choose the larger value, rather than averaging the two policies.

- https://cdn.aaai.org/AAAI/1994/AAAI94-157.pdf
- https://www.pomdp.org/tutorial/pomdp-solving.html
- Local: TEACHING_NOTES.md, demo/README.md and visuals/commitment_values.svg. Examples A and B are TA-created.
- Existing reference: Class18-POMDPs.pdf, whose title page is documented as Class 17. Use printed slide numbers. PDF not found locally; not claimed as reviewed.

### 31. The sensing tree also has a vector

Evaluate the same contingent tree separately from L and from R. Timing: 1.5 minutes. Visual: senseAlpha. Existing professor reference: Class18-POMDPs.pdf printed slides 13–19.

The fixed tree is sense then commit L after red and R after blue. Starting in true L, red probability .9 yields correct reward10 and blue .1 yields incorrect reward minus10, minus sensing cost1: alpha entry7. Starting in true R, red .2 is incorrect and blue .8 correct, minus1: entry5. Their belief dot product is5+2p, giving6 at uniform belief. The plot here compares the two immediate commitments with this additional fixed tree, unlike the previous commitment-only plot. For cost1 the maximum of these three lines also covers the finite sense-once problem because always choosing one commitment after sensing is dominated by committing immediately, and the opposite contingent tree is dominated. General-prior decision-region details stay in backup3. State the finite-model/horizon conditions for piecewise-linear convex optimal values.

- `α_{sense}(L) = −1 + 0.9(10) + 0.1(−10) = 7`
- `α_{sense}(R) = −1 + 0.2(−10) + 0.8(10) = 5`
- `b^T α_{sense} = 7p + 5(1−p) = 5 + 2p`

At p = 0.5: the fixed sensing tree gives 6.

- https://cdn.aaai.org/AAAI/1994/AAAI94-157.pdf
- https://www.pomdp.org/tutorial/pomdp-solving.html
- Local: TEACHING_NOTES.md, demo/README.md and visuals/commitment_values.svg. Examples A and B are TA-created.
- Existing reference: Class18-POMDPs.pdf, whose title page is documented as Class 17. Use printed slide numbers. PDF not found locally; not claimed as reviewed.

### 32. Why planning remains difficult

Compact beliefs do not make every POMDP easy to solve. Timing: 1 minutes. Visual: complexity. Existing professor reference: Class18-POMDPs.pdf printed slides 17–39 (preparation only).

The belief space is continuous even for two hidden states. A policy can branch on every future observation, and the number of possible trees or alpha-vector candidates grows quickly with horizon. A belief estimator gives the state of knowledge, but a planner must compare future contingent consequences. Finite-state/action/observation and finite horizon yield a piecewise-linear convex value representation; this does not mean it is always small or computationally cheap. Infinite-horizon and continuous-model cases require further qualifications. Keep pruning, point-based methods and POMCP as preparation/backup context rather than teaching solver internals live. Week11 remains a homework walkthrough once the homework exists; no new problem or solution is created here.

Today: model → belief update → contingent decision → value representation.

- https://cdn.aaai.org/AAAI/1994/AAAI94-157.pdf
- https://www.pomdp.org/tutorial/pomdp-solving.html
- Local: TEACHING_NOTES.md, demo/README.md and visuals/commitment_values.svg. Examples A and B are TA-created.
- Existing reference: Class18-POMDPs.pdf, whose title page is documented as Class 17. Use printed slide numbers. PDF not found locally; not claimed as reviewed.

### 33. Questions & recap

Reconstruct the update, then explain the decision. Timing: 3 minutes. Visual: recap. Existing professor reference: Class18-POMDPs.pdf printed slides 2–19.

Use three minutes for questions and checks. Does random motion alone imply partial observability? What differs between physical state, observation and belief? Which table direction produces the prediction? Why is P(red|L) not P(L|red)? From what distribution do the blue and red alternatives begin? Why must Example B reset the prior? Explain the max over actions versus expectation over observations in Bellman planning. Why can paying for information improve reward, and when is it too expensive? Distinguish a belief vector from an alpha-vector and a commitment-only plot from the sensing strategy. Do not invent homework tasks; link these skills to the planned Week11 walkthrough without claiming the assignment is available.

Predict → weight → normalize → choose from the belief.

- https://cdn.aaai.org/AAAI/1994/AAAI94-157.pdf
- https://www.pomdp.org/tutorial/pomdp-solving.html
- Local: TEACHING_NOTES.md, demo/README.md and visuals/commitment_values.svg. Examples A and B are TA-created.
- Existing reference: Class18-POMDPs.pdf, whose title page is documented as Class 17. Use printed slide numbers. PDF not found locally; not claimed as reviewed.

### 34. Full conditioning and impossible evidence

The Bayesian update follows the chosen post-action model. Timing: 0 minutes. Visual: equations. Existing professor reference: Class18-POMDPs.pdf printed slides 10.

Condition on the old history and chosen action. The Markov dynamics remove dependence on earlier history once the old state/action are given. The sensor conditional-independence assumption removes dependence on history given resulting state/action. Marginalize over the old state for the numerator and resulting states for the normalizer. A zero normalizer is a genuine impossible-event conditioning case in the ideal model; it may also reflect a misspecified sensor, wrong convention, impossible prior support, or numerical underflow in an implementation. Log-domain arithmetic can address underflow but cannot give a uniquely correct posterior to an event assigned zero probability by the model. If observed rewards reveal extra hidden-state information, condition on them through an expanded observation model.

- `P(s′,o | h_t,a) = O(s′,a,o) ∑_s Tr(s,a,s′)b_t(s)`
- `P(s′ | h_t,a,o) = P(s′,o | h_t,a) / P(o | h_t,a)`
- `Z = 0: every state with predicted mass gives likelihood zero.`
- `Do not replace an undefined posterior with a fabricated distribution.`

Informative rewards or other evidence belong in history and the model.

- https://cdn.aaai.org/AAAI/1994/AAAI94-157.pdf
- https://www.pomdp.org/tutorial/pomdp-solving.html
- Local: TEACHING_NOTES.md, demo/README.md and visuals/commitment_values.svg. Examples A and B are TA-created.
- Existing reference: Class18-POMDPs.pdf, whose title page is documented as Class 17. Use printed slide numbers. PDF not found locally; not claimed as reviewed.

### 35. Matrix conventions and posterior odds

Likelihood ratios quantify how evidence changes relative support. Timing: 0 minutes. Visual: equations. Existing professor reference: Class18-POMDPs.pdf printed slides 10.

The posterior normalizer cancels in the ratio. Red multiplies L-versus-R predicted odds by.9/.2=4.5; blue multiplies them by.1/.8=.125. Prediction odds .52/.48=13/12 become red39/8=4.875 and blue13/96. Converting odds x to probability x/(1+x) gives the same posterior as direct normalization. If denominators vanish, use the original probability equations rather than dividing blindly. Different sources use row or column beliefs and different transition indexing; state the convention before multiplying. D is a diagonal likelihood matrix, not a normalized belief or a general dynamics operator. This alternative formulation is a checking tool, not a replacement for conditioning on the correct observation time.

- `Column belief: b̄ = T_a^T b;    row belief: b̄^T = b^T T_a`
- `D_{red} = diag(0.9,0.2);    D_{blue} = diag(0.1,0.8)`
- `b^{ao}(L) / b^{ao}(R) = [O(L,a,o)/O(R,a,o)] × [b̄(L)/b̄(R)]`
- `Red multiplier: 4.5;    blue multiplier: 0.125`

Odds formula requires nonzero denominator terms.

- https://cdn.aaai.org/AAAI/1994/AAAI94-157.pdf
- https://www.pomdp.org/tutorial/pomdp-solving.html
- Local: TEACHING_NOTES.md, demo/README.md and visuals/commitment_values.svg. Examples A and B are TA-created.
- Existing reference: Class18-POMDPs.pdf, whose title page is documented as Class 17. Use printed slide numbers. PDF not found locally; not claimed as reviewed.

### 36. General priors and sensing regions

Cost 1 · same sensor · commit now or sense once. Timing: 0 minutes. Visual: generalPrior. Existing professor reference: Class18-POMDPs.pdf printed slides 11–19.

For general prior p, red weights .9p and .2(1-p) favor L iff1.1p>=.2, yielding2/11. Blue weights .1p and .8(1-p) favor R iff.9p<=.8, yielding8/9. Between those thresholds the optimal post-sense contingent policy is redL/blueR. Its cost1 value5+2p exceeds commitR10-20p whenp>5/22 and exceeds commitL20p-10 whenp<5/6. Both intersection bounds lie inside the branch-choice region. Outside the branch-choice region, sensing leads to the same commitment either way and wastes its positive cost. For general costc, this fixed tree alpha is(8-c,6-c); its value is6-c+2p. At uniform prior the thresholdc<7 follows. Do not apply the cost1 belief interval unchanged to other costs, or confuse branch-action thresholds with sense-versus-commit thresholds.

- `Red → choose L when p ≥ 2/11.`
- `Blue → choose R when p ≤ 8/9.`
- `Fixed tree (red L, blue R): V = 5 + 2p`
- `Sense beats both immediate commitments for 5/22 < p < 5/6.`

At the region boundaries, sensing and a commitment tie.

- https://cdn.aaai.org/AAAI/1994/AAAI94-157.pdf
- https://www.pomdp.org/tutorial/pomdp-solving.html
- Local: TEACHING_NOTES.md, demo/README.md and visuals/commitment_values.svg. Examples A and B are TA-created.
- Existing reference: Class18-POMDPs.pdf, whose title page is documented as Class 17. Use printed slide numbers. PDF not found locally; not claimed as reviewed.

### 37. Policy-tree alpha-vector recursion

One root action and one fixed continuation tree per observation. Timing: 0 minutes. Visual: equations. Existing professor reference: Class18-POMDPs.pdf printed slides 13–19.

A fixed contingent tree chooses a root action a and specifies a continuation tree for each observation. Evaluate root reward plus discounted expected continuation, summing transitions and resulting-state observation likelihoods. Alpha_o(s-prime) is the fixed branch policy value from that resulting state. Dotting with belief yields expected tree value and explains its linearity. For the sensing example, identity transition and gamma1 simplify the recursion to statewise observation-weighted commitment rewards minus cost1. Hadamard product symbol means componentwise multiplication. Work explicitly: -1+.9*10+.1*(-10)=7; in stateR, -1+.2*(-10)+.8*10=5. This is an illustrative backup derivation, not an implementation of all candidate-tree backups, cross sums or pruning.

- `α(s) = R(s,a)`
- `       + γ ∑_{s′} Tr(s,a,s′) ∑_o O(s′,a,o) α_o(s′)`
- `Sense: Tr = I, γ = 1, R = −1`
- `α = −1 + O(red) ⊙ (10,−10) + O(blue) ⊙ (−10,10) = (7,5)`

αₒ is the continuation vector selected for observation o.

- https://cdn.aaai.org/AAAI/1994/AAAI94-157.pdf
- https://www.pomdp.org/tutorial/pomdp-solving.html
- Local: TEACHING_NOTES.md, demo/README.md and visuals/commitment_values.svg. Examples A and B are TA-created.
- Existing reference: Class18-POMDPs.pdf, whose title page is documented as Class 17. Use printed slide numbers. PDF not found locally; not claimed as reviewed.

### 38. A map of solution approaches

Belief filtering and policy computation are separate tasks. Timing: 0 minutes. Visual: solverMap. Existing professor reference: Class18-POMDPs.pdf printed slides 17–39 (preparation only).

Exact finite-horizon dynamic programming can enumerate and prune alpha-vector candidates, but tree/observation combinations grow rapidly. Point-based methods approximate value using selected beliefs rather than requiring an exhaustive representation. Online planners focus computation on the current belief; POMCP is one simulation-based approach using history trees and particles. These are a brief orientation, not runnable code, derivations, performance comparisons or a replacement for the Week11 assignment walkthrough. A probability filter only maintains belief; it does not automatically solve which sensing or control action is best. The small examples establish the foundational model/update/decision logic, not scaling guarantees. The original professor slide references are preserved from local notes; advanced printed sections were not reviewed from the unavailable PDF.

No advanced solver or homework solution is implemented here.

- https://cdn.aaai.org/AAAI/1994/AAAI94-157.pdf
- https://www.pomdp.org/tutorial/pomdp-solving.html
- Local: TEACHING_NOTES.md, demo/README.md and visuals/commitment_values.svg. Examples A and B are TA-created.
- Existing reference: Class18-POMDPs.pdf, whose title page is documented as Class 17. Use printed slide numbers. PDF not found locally; not claimed as reviewed.

## Numerical models and checks

Example A: prior (0.6,0.4), transition rows [0.8,0.2] and [0.1,0.9]; sensor rows L: red0.9/blue0.1 and R: red0.2/blue0.8. Column prediction T-transpose b = (0.52,0.48). Red weights (0.468,0.096), probability0.564, posterior(0.8297872340,0.1702127660). Blue weights(0.052,0.384), probability0.436, posterior(0.1192660550,0.8807339450). These observations are alternatives. Expected posterior equals predicted belief.

Example B: reset to (0.5,0.5), identity sensing transition, cost1, terminal correct/incorrect rewards +10/-10, gamma1, at most sense once then commit. Observation probabilities0.55/0.45, posteriors(9/11,2/11) and(1/9,8/9). Conditional best commitment values70/11 and70/9; sensing value6 and correctness0.85. At uniform prior cost threshold7. Commitment vectors(10,-10),(-10,10); fixed sensing vector(7,5), line5+2p. At cost1 the three-line envelope prefers sensing for5/22<p<5/6, with endpoint ties. The commitment-only plot is kept distinct from this expanded comparison.

## Validation and provenance

Read all four original Week10 files. Protect the three files outside the intentionally revised presentation plan via SHA-256. The professor PDF was not found locally; retain filename/title-page discrepancy and printed references without claiming review. Sources are primary paper and author tutorial. Verify38 slides, all notes, five hidden backups34–38,38 PDF pages, sequential exercise16/answer17, all previews, equations, sums, ratios and exact38+4+3 timing. No ROS, MuJoCo, software-demo execution or new homework is required. Independent PowerShell arithmetic checks and PowerPoint rendering are recorded under slides/.