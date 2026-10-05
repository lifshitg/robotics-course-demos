# Week 12 — SLAM and Bayesian Estimation

**30 minutes explanation + 12 minutes integrated visualization + 3 minutes recap.** 38 English slides, including five hidden backups. The new schedule supersedes timing in the preserved teaching notes. The updated range-only demo selects known-map localization or unknown-map joint estimation; all physical landmarks stay fixed.

## Sequence and timing

| Slide | Topic | Minutes |
|---|---|---:|
| 1 | SLAM & Bayesian estimation | 0 |
| 2 | Why SLAM? | 1 |
| 3 | Localization, mapping, SLAM | 1 |
| 4 | Define the symbols | 1 |
| 5 | What does SLAM estimate? | 1 |
| 6 | The SLAM process | 1 |
| 7 | Bayesian prediction & correction | 1.5 |
| 8 | Our range-only visualization | 1 |
| 9 | Live: inspect the initial belief | 1 |
| 10 | A belief made of particles | 1 |
| 11 | Predict with the motion model | 1 |
| 12 | Live: predict before pressing | 2 |
| 13 | Predict ranges; score agreement | 1.5 |
| 14 | Weight, then normalize | 1 |
| 15 | Calculate three posterior weights | 1.5 |
| 16 | Live: reveal weighting | 2 |
| 17 | Resample plausible hypotheses | 1 |
| 18 | Live: reveal resampling | 2 |
| 19 | Uncertainty and failure | 1 |
| 20 | When the map is unknown | 1 |
| 21 | Pose errors distort the map | 1.5 |
| 22 | Which landmark was observed? | 1 |
| 23 | Range-only landmark estimation | 1.5 |
| 24 | Live: switch to range-only SLAM | 5 |
| 25 | Drift and recognized revisits | 1.5 |
| 26 | Occupancy-grid mapping | 1.5 |
| 27 | Each robot hypothesis carries a map | 1 |
| 28 | SLAM does not require particles | 1 |
| 29 | The Kalman-filter idea | 1 |
| 30 | EKF-SLAM: linearize the models | 1.5 |
| 31 | Why cross-covariance matters | 1 |
| 32 | Reconstruct the complete process | 1 |
| 33 | Questions & recap | 3 |
| 34 | Joint posterior and reference frame (hidden) | 0 |
| 35 | Likelihoods and systematic selection (hidden) | 0 |
| 36 | Range-only conditional-map update (hidden) | 0 |
| 37 | Kalman/EKF covariance and checks (hidden) | 0 |
| 38 | Maps and graph-based SLAM (hidden) | 0 |

## Slide guidance, mathematics, and references

### 1. SLAM & Bayesian estimation

Week 12 · Where am I, and what surrounds me? Visual: title. Timing: 0 minutes.

Students know coordinate transforms and Week10 beliefs. Explain the same physical scene first with a known map, then with unknown landmark positions. Both modes use range only. The simulator knows truth; the estimator never receives it. Heading is fixed in the demo. Thirty minutes of explanation, twelve minutes of visualization integrated at five points, and three minutes recap. The preserved teaching notes describe the older localization lesson; this plan and updated demo README define the revised session.

Source: https://www-personal.acfr.usyd.edu.au/tbailey/papers/slamtute1.pdf

### 2. Why SLAM?

An unfamiliar environment gives us two unknowns. Visual: coupling. Timing: 1 minutes.

SLAM means simultaneous localization and mapping. A robot needs a map to interpret measurements, but needs its pose to place those measurements in the map. Examples include exploring a warehouse, inspecting an unfamiliar building, and autonomous navigation. SLAM estimates geometry and uncertainty; it is not motion planning, obstacle avoidance, or semantic scene understanding by itself. Start with this question before introducing particles so the main subject remains SLAM.

Estimate the robot and its surroundings together.

Source: https://www-personal.acfr.usyd.edu.au/tbailey/papers/slamtute1.pdf

### 3. Localization, mapping, SLAM

The distinction is what is given and what is estimated. Visual: comparison. Timing: 1 minutes.

Localization: given a map, infer robot state. Mapping: given robot poses, infer the map. SLAM: estimate both from controls and sensor evidence. The new selector changes whether map positions are known, not whether landmarks physically move. A static unknown map is standard SLAM. Both modes retain the same robot motion and range sensor. The teaching example supplies landmark identities and fixed heading; real SLAM can require association and orientation estimation.

Fixed landmarks can still have unknown positions.

Source: https://www-personal.acfr.usyd.edu.au/tbailey/papers/slamtute1.pdf

### 4. Define the symbols

A pose is more than a position; a map contains many landmarks. Visual: notation. Timing: 1 minutes.

Define t as time, j as landmark index, i later as particle index. General planar pose x_t has position and heading. Each m_j is a two-dimensional static landmark position. Commands u_t produce uncertain motion; observations z_t provide noisy evidence. Correspondence c_t identifies the observed landmark. The existing demo instead estimates p_t=(x,y), holds heading fixed, and observes all three identified landmarks each cycle. Uppercase random quantities can be distinguished from concrete numerical samples; p(·) denotes a probability density, not the position vector p_t.

`x_t = (x, y, θ);     m = {m_1, …, m_J}`

`u_t: command;  z_t: observation;  c_t: landmark ID`

Demo state: p_t = (x,y); heading is fixed.

Source: https://www-personal.acfr.usyd.edu.au/tbailey/papers/slamtute1.pdf

### 5. What does SLAM estimate?

A joint belief, rather than two independent guesses. Visual: equations. Timing: 1 minutes.

Read every term: trajectory x_0 through x_t and map m conditioned on accumulated controls, observations, and associations. Full SLAM retains a trajectory posterior; online SLAM estimates the current pose and map after marginalizing past poses. They differ in representation and what can be revised. The demo stores current robot particles and maps conditional on their sampled histories, without retaining a global trajectory optimizer. Its known-map mode conditions on supplied m instead. Fix a reference frame through an initial pose prior; relative observations alone do not reveal a unique absolute world origin.

`p(x_{0:t}, m | u_{1:t}, z_{1:t}, c_{1:t})`

`Online: p(x_t, m | u_{1:t}, z_{1:t}, c_{1:t})`

Robot and map uncertainty are correlated.

Source: https://www-personal.acfr.usyd.edu.au/tbailey/papers/slamtute1.pdf

### 6. The SLAM process

Use motion and observations repeatedly, maintaining uncertainty. Visual: workflow. Timing: 1 minutes.

Explain the cycle: move and predict, collect observations, associate them with landmarks, update the joint estimate, then continue. New landmarks need initialization; repeated landmarks refine existing estimates. A recognized revisit supplies a constraint between observations and previously estimated structure. Different algorithms store and process these constraints differently. Known IDs remove association search in the demo. Static landmark coordinates do not move during prediction; their estimated probabilities change when evidence arrives.

Move → predict → observe → associate → update.

Source: https://www-personal.acfr.usyd.edu.au/tbailey/papers/slamtute1.pdf

### 7. Bayesian prediction & correction

Week 10 beliefs, now over continuous robot states. Visual: equations. Timing: 1.5 minutes.

These equations first describe known-map localization. The integral averages motion outcomes over every possible previous state x-prime. Prediction uses controls and the motion model, not the new measurement. Correction multiplies the predicted density by observation likelihood and normalizes with eta. The normalizer is the integral of numerator density over states. For SLAM the belief includes map variables too. Measurements affect robot and map jointly. This is estimation, unlike a POMDP planner choosing an action to optimize reward. State definitions and measurement timing must remain consistent.

`b̄_t(x) = ∫ p(x | x′,u_t) b_{t−1}(x′) dx′`

`b_t(x) = η p(z_t | x,m) b̄_t(x)`

Prediction spreads possibilities; evidence changes plausibility.

Source: https://www.cs.cmu.edu/~thrun/papers/fox.aaai99.pdf

Source: https://www-personal.acfr.usyd.edu.au/tbailey/papers/slamtute1.pdf

### 8. Our range-only visualization

Same scene and sensor; different knowledge about the map. Visual: scene. Timing: 1 minutes.

Exact model: 500 particles with Gaussian initial mean (2,2) and standard deviation .6 m per axis. Identified landmarks have true positions (0,0),(6,0),(0,6), known only in localization. Commands are eight .25 m translations along each of +x,+y,-x,-y. Motion standard deviation is .08 m per axis; range sigma is .15 or .60 m. The orange star is teaching-only truth; red X is weighted position estimate. Separate random streams drive true motion, sensor noise, and estimation. Gaussian ranges are an idealization and are not clipped. Display borders are not walls.

Localization knows coordinates; SLAM knows only IDs.

Source: https://www-personal.acfr.usyd.edu.au/tbailey/papers/slamtute1.pdf

### 9. Live: inspect the initial belief

Localization mode · What would the real robot know? Visual: demo. Timing: 1 minutes.

One minute. Start in Localization: known map and .15 m noise. Identify black known landmark squares, orange truth star, red estimate, and weighted particles. Ask which is hidden from the estimator: the simulator truth star. A particle is a hypothetical position, not another robot. Show truth can be turned off without changing estimation. Keep the map selector in localization until the later unknown-map segment. If the window cannot open, use the included initial localization figure.

Known landmarks + uncertain robot position.

Source: https://www.cs.cmu.edu/~thrun/papers/fox.aaai99.pdf

### 10. A belief made of particles

A weighted set of hypotheses approximates a distribution. Visual: particles. Timing: 1 minutes.

Each particle is a possible state. Delta denotes point mass at that hypothesis, not a tiny physical robot or a continuous Gaussian. Weights sum to one. The weighted mean summarizes the belief but can lie between two modes where little probability exists. A cloud can represent nonlinear or multimodal uncertainty, but finite sampling can miss a true region. Initial distributions and noise assumptions matter. The demo is roughly initialized tracking, not global localization or kidnapped-robot recovery.

`b_t(x) ≈ ∑_i w_t^{(i)} δ(x − x_t^{(i)})`

`∑_i w_t^{(i)} = 1;     p̂_t = ∑_i w_t^{(i)}p_t^{(i)}`

A mean is a summary, not the whole belief.

Source: https://www.cs.cmu.edu/~thrun/papers/fox.aaai99.pdf

### 11. Predict with the motion model

Move every robot hypothesis with its own sampled uncertainty. Visual: equations. Timing: 1 minutes.

The command is a .25 m axis-aligned translation in the next direction. Each hypothesis gets independent Gaussian motion noise. Simulator truth also moves noisily, using a separate stream. No sensor evidence has been consumed in Prediction. In SLAM the landmark grids remain fixed during this step because landmarks are static. Motion uncertainty broadens the predictive distribution in expectation; one finite realization need not visibly broaden. Do not promise the true square path closes perfectly.

`p_t^{(i)} = p_{t−1}^{(i)} + u_t + ε_t^{(i)}`

`ε_t^{(i)} ∼ N(0, 0.08² I)`

No new measurement is used yet.

Source: https://www.cs.cmu.edu/~thrun/papers/fox.aaai99.pdf

### 12. Live: predict before pressing

Next stage → Prediction Visual: demo. Timing: 2 minutes.

Two minutes. Ask where the cloud will move and whether all dots should move identically. Press Next stage once. Compare with the prior and point out noisy displacement. The range panel says no new observation yet. The truth trajectory is only explanatory. Ask whether static map coordinates should also move: no. Use the saved prediction figure if needed.

What moves? What information is still missing?

Source: https://www.cs.cmu.edu/~thrun/papers/fox.aaai99.pdf

### 13. Predict ranges; score agreement

Likelihood rewards hypotheses that explain the measurement. Visual: equations. Timing: 1.5 minutes.

Range is Euclidean distance, not bearing. At p=(2,2), the three predicted ranges are sqrt8≈2.8284 and sqrt20≈4.4721 twice. Independent Gaussian range errors justify multiplying three likelihoods, or summing their log likelihoods. The squared residual is divided by sensor variance through the standardized residual. Larger sigma makes the same discrepancy less surprising. These are continuous probability densities, not probabilities of exact readings. Shared Gaussian normalization constants cancel when normalizing robot weights in localization.

`h_j(p) = ‖m_j − p‖₂;    z_{t,j} = h_j(p_t) + ν_{t,j}`

`ν_{t,j} ∼ N(0, σ_{z}²)`

`L_i ∝ exp[−½ ∑_j ((z_{t,j} − h_j(p_t^{(i)}))/σ_z)²]`

σ_z = 0.15 m or 0.60 m.

Source: https://www.cs.cmu.edu/~thrun/papers/fox.aaai99.pdf

### 14. Weight, then normalize

Keep particle positions; change their relative plausibility. Visual: equations. Timing: 1 minutes.

The prior weight matters: evidence multiplies the previous belief, rather than discarding it. These equations use the demo bootstrap proposal, sampled from the motion model. More general importance-sampling proposals require a proposal correction. During correction robot coordinates remain unchanged. The weighted estimate may nevertheless move because its averaging weights changed. The demo computes log weights, subtracts the maximum, exponentiates and normalizes to avoid numerical underflow. Invalid likelihoods raise an error, not a fabricated uniform posterior.

`w̃_i = w_{t−1}^{(i)} L_i`

`w_t^{(i)} = w̃_i / ∑_k w̃_k`

The estimate can move while the dots stay fixed.

Source: https://www.cs.cmu.edu/~thrun/papers/fox.aaai99.pdf

### 15. Calculate three posterior weights

Equal priors · likelihoods 0.6, 0.3, 0.1 Visual: weights. Timing: 1.5 minutes.

Work before showing the answer. Multiply each likelihood by prior 1/3: .2,.1,1/30. The normalizer is 1/3. Division yields .6,.3,.1. Likelihoods need not sum to one across hypotheses; these chosen numbers happen to do so. Expected copies out of ten are 6,3,1. For general random resampling those are expectations, not fixed counts; the systematic method happens to give exactly these counts for this particular integer-count example. This table is a teaching calculation, not a trace from the 500-particle model.

Normalizer = 1/3; posterior weights sum to 1.

Source: https://www.cs.cmu.edu/~thrun/papers/fox.aaai99.pdf

### 16. Live: reveal weighting

Next stage → Weighting Visual: demo. Timing: 2 minutes.

Two minutes. Ask students what should change. Press once and compare particle locations with the prediction state: positions did not move. Sizes/colors and red weighted estimate change. Read the three ranges and connect disagreement to likelihood. Ground truth is not used. The saved weighting image provides fallback. Keep one extra click for resampling, rather than allowing playback to skip the discussion.

Why does the red estimate move?

Source: https://www.cs.cmu.edu/~thrun/papers/fox.aaai99.pdf

### 17. Resample plausible hypotheses

Copy by probability; reset weights after selection. Visual: resample. Timing: 1 minutes.

The systematic algorithm takes one random offset and equally spaced thresholds on the cumulative weight distribution. It is not N independent random draws, although each ancestor has the correct expected copy count. Duplicates are allowed and can overlap. Selection frequency encodes the previous weights, so new particles receive equal weights. Resampling adds no evidence and does not guarantee improved accuracy; it can lose diversity. The demo resamples every measurement. Effective-sample-size adaptive schedules exist, but are not implemented.

`P(select i) = w_i;    new weights = 1/N`

SLAM must copy the robot AND its conditional map.

Source: https://www.cs.cmu.edu/~thrun/papers/fox.aaai99.pdf

Source: https://www.cs.cmu.edu/~thrun/papers/montemerlo.fastslam-tr.pdf

### 18. Live: reveal resampling

Next stage → Resampling Visual: demo. Timing: 2 minutes.

Two minutes. Ask whether another measurement is taken: no. Press once and show equal weights and overlapping copies. The estimate may shift due to finite resampling. If needed, play a few cycles then pause; do not consume the later SLAM comparison time. Reset retains selected noise and mode. Discuss what would go wrong if a SLAM particle kept a map from a different ancestor.

Uniform weights do not mean uniform spatial belief.

Source: https://www.cs.cmu.edu/~thrun/papers/fox.aaai99.pdf

Source: https://www.cs.cmu.edu/~thrun/papers/montemerlo.fastslam-tr.pdf

### 19. Uncertainty and failure

A tight cloud can still be wrong. Visual: cards. Timing: 1 minutes.

Noisier observations usually constrain belief less sharply, but individual outcomes vary and entropy is not guaranteed to fall at every update. Gaussian models can be wrong. Finite samples may miss correct hypotheses, and repeated resampling can eliminate useful paths. Means can lie between modes. Grid bounds and resolution affect the SLAM approximation. The same initial robot prior anchors the map imperfectly; no absolute truth recovery guarantee follows. The preset switch pauses and resets, so comparison is not a sudden noise change during the same trajectory.

Model mismatch · missing hypotheses · lost diversity

Source: https://www-personal.acfr.usyd.edu.au/tbailey/papers/slamtute1.pdf

### 20. When the map is unknown

The same range now constrains robot AND landmark locations. Visual: coupling. Timing: 1 minutes.

Localization interprets the observation against supplied m_j. In SLAM both terms are uncertain and must be inferred jointly. All landmarks remain static. Unknown map does not mean physically unstable objects. The SLAM estimator receives identified ranges, a generic bounded map prior, and a robot prior; no true coordinates. Both modes use exactly the same simulated range-only sensor and seeded physical motion. Mapping uncertainty is maintained per robot hypothesis, preserving coupling through a mixture of conditional maps.

`z_{t,j} ≈ ‖m_j − p_t‖₂`

Static landmarks; unknown coordinates.

Source: https://www-personal.acfr.usyd.edu.au/tbailey/papers/slamtute1.pdf

### 21. Pose errors distort the map

Frame mathematics explains the coupling. Visual: transform. Timing: 1.5 minutes.

Define R as rotation from the robot frame to world and t as world position of the robot origin. A local point observation (1,0), robot translation (2,2), and heading90 degrees yields landmark (2,3). Using heading0 incorrectly yields (3,2). This local point requires direction information; it is a conceptual alternative sensor example, NOT a measurement provided by the range-only demo. The demo instead constrains distance circles. Pose errors affect map placement, and map errors affect pose estimation. Relative sensing also leaves global reference-frame freedoms without an anchor.

`m_j = t_t + R(θ_t) z_j^{local}`

R = rotation; t = translation. Example needs direction information.

Source: https://www-personal.acfr.usyd.edu.au/tbailey/papers/slamtute1.pdf

### 22. Which landmark was observed?

Data association connects observations to map features. Visual: association. Timing: 1 minutes.

Explain existing landmark match, new landmark initialization, and ambiguous or incorrect correspondence. The demo assumes exactly three landmarks with known IDs L1,L2,L3, so it avoids matching and discovery. This is a modeling simplification, not a solved real-world association problem. A mistaken association can create a false strong constraint and damage an estimate or loop closure. Matching may use geometry and appearance, uncertainty gates and consistency checks. Keep implementation detail in notes rather than turning this into a separate association lecture.

Demo IDs are supplied; real systems must often infer them.

Source: https://www-personal.acfr.usyd.edu.au/tbailey/papers/slamtute1.pdf

### 23. Range-only landmark estimation

One reading gives a circle; new viewpoints narrow the possibilities. Visual: circles. Timing: 1.5 minutes.

Conditional on one known robot hypothesis, a noisy distance produces an annular probability band around it. It does not uniquely initialize a point or narrow Gaussian. Two circles may intersect at two possibilities; collinear viewpoints can retain a reflection ambiguity. A third noncollinear viewpoint can distinguish them under suitable geometry. If robot position is uncertain, integrating its hypotheses adds further uncertainty. The demo uses full grid distributions to retain these modes. The shown coordinate mean can lie in the center of a ring where probability is low. Do not introduce bearings into the implemented sensor.

`‖m_j − p_t‖₂ ≈ z_{t,j}`

Mean ≠ most likely landmark location.

Source: https://www-personal.acfr.usyd.edu.au/tbailey/papers/slamtute1.pdf

### 24. Live: switch to range-only SLAM

SLAM: unknown map · Same physical landmarks and sensor Visual: slamdemo. Timing: 5 minutes.

Five minutes. Pause, select SLAM: unknown map; this resets while preserving noise and seed. Show initial uniform landmark grids and known IDs. Advance prediction then weighting: select L1,L2,L3 detail heatmaps and point out annular or ambiguous distributions. Resample: selected robot hypotheses bring their maps. Use prepared post-resampling snapshots at motions8,16,32 to show longer-term constraints without waiting for full playback. Show truth off and explain the mean marker is not a unique solution. Briefly switch sigma to .60m, noting the reset and generally less informative measurements. The grid is a bounded prior over landmark coordinates, not occupancy cells or walls. Repeated landmark IDs are observed; no explicit place-recognition/trajectory optimizer exists.

A circle → overlapping constraints → a more informative map.

Source: https://www-personal.acfr.usyd.edu.au/tbailey/papers/slamtute1.pdf

### 25. Drift and recognized revisits

Revisiting a place is useful only when the correspondence is recognized. Visual: loop. Timing: 1.5 minutes.

Odometry errors accumulate and distort trajectories/maps. A valid revisit constraint can improve consistency by relating current observations to earlier structure. Merely returning near the start is not loop closure. The filter demo repeatedly reobserves supplied landmark IDs, refining joint estimates; it has no separate loop-closure detector, global trajectory optimizer, or past-pose correction display. Explain graph-based loop constraints conceptually with an editable original diagram. No guarantee that a false match helps, or that all map errors vanish. Static maps, sensible noise models, and correct association are assumptions.

Reobservation is implemented; global loop optimization is not.

Source: https://www-personal.acfr.usyd.edu.au/tbailey/papers/slamtute1.pdf

Source: https://www.roboticsbook.org/S64_driving_perception.html

### 26. Occupancy-grid mapping

A different map representation: free, occupied, or unknown. Visual: equations. Timing: 1.5 minutes.

Here c denotes a cell, distinct from association c_t. Logit(p)=log(p/(1-p)); .5 prior gives zero log odds. An inverse sensor model contributes free-space evidence before a hit and occupied evidence near a hit; untouched cells remain unknown. A toy occupied probability .7 adds log(7/3)≈.8473; two consistent updates with .5 prior produce probability49/58≈.8448. Conditional cell independence and supplied poses are mapping approximations. Handling uncertain trajectories jointly is SLAM. The demo landmark probability grids are NOT occupancy grids: each represents one landmark location and sums to one across locations. Occupancy cells each have their own Bernoulli probability.

`ℓ_t(c) = ℓ_{t−1}(c) + logit P(c occupied | z_t,x_t) − ℓ_0(c)`

`P(c occupied) = 1 / (1 + exp(−ℓ_t(c)))`

HW6 connection; occupancy mapping is not implemented here.

Source: https://www.cs.cmu.edu/~thrun/papers/thrun.iros01-occmap.pdf

### 27. Each robot hypothesis carries a map

Grid-based range-only SLAM uses conditional landmark distributions. Visual: conditional. Timing: 1 minutes.

Read i as robot/path hypothesis, j as landmark ID, and g as candidate grid coordinate. Integrate the likelihood against the OLD map to score robot hypotheses. Then update each conditional map with that reading. Weight robot particles by the product of evidences for conditionally independent landmarks. Resampling copies whole hypotheses. Each landmark prior is uniform on an81x81 grid spanning -2 through8m at .125m spacing. This is a finite-grid Rao-Blackwellized method inspired by the FastSLAM decomposition, not the original landmark-EKF algorithm. Original FastSLAM combines particles with landmark Kalman filters; particles and Kalman methods are not mutually exclusive.

`e_{ij} = ∑_g L_{ij}(g) M_{t−1,ij}(g)`

`M_{t,ij}(g) ∝ L_{ij}(g) M_{t−1,ij}(g)`

Evidence first; posterior map second; copy them together.

Source: https://www.cs.cmu.edu/~thrun/papers/montemerlo.fastslam-tr.pdf

### 28. SLAM does not require particles

Choose a representation suited to the model and uncertainty. Visual: methods. Timing: 1 minutes.

Particle methods can retain multiple modes but require adequate hypotheses and computation. KF is exact for linear Gaussian models with Gaussian initial belief. Nonlinear SLAM commonly uses EKF or UKF approximations; a single Gaussian can struggle with severe ambiguity. Graph-based methods optimize constraints and are not simply another filter. No method is universally best. Pose/map representation, association, sparsity, computation, and noise assumptions all matter. Our range-only ring distributions motivate the grid maps; a narrow Gaussian at first range would invent information.

Particle filters · Gaussian filters · graph optimization

Source: https://www-personal.acfr.usyd.edu.au/tbailey/papers/slamtute1.pdf

Source: https://www.cs.cmu.edu/~thrun/papers/montemerlo.fastslam-tr.pdf

Source: https://www.roboticsbook.org/S64_driving_perception.html

### 29. The Kalman-filter idea

Represent uncertainty with a mean and covariance. Visual: equations. Timing: 1 minutes.

Define mu mean, Sigma covariance, F dynamics matrix, B command mapping, H measurement matrix, Q process covariance and C_z sensor covariance. Use C_z rather than R to avoid collision with rotation notation. Innovation e is measured minus predicted evidence; S is its covariance; K balances model uncertainty and measurement uncertainty. For scalar prior mean2 variance.36, command.25, Q=.0064, position observation2.4 with C_z=.0225: predicted2.25 variance.3664, gain.9421445, posterior mean2.3913217 and variance.0211983. This is a separate direct-position-sensor example, NOT the demo ranges. In code solve linear systems rather than explicitly invert S. More complete covariance equations appear in backup.

`μ̄ = Fμ + Bu;     Σ̄ = FΣF^T + Q`

`e = z − Hμ̄;    S = HΣ̄H^T + C_z`

`K = Σ̄H^T S^{−1};    μ⁺ = μ̄ + Ke`

Linear Gaussian assumptions make this update exact.

Source: https://www-personal.acfr.usyd.edu.au/tbailey/papers/slamtute1.pdf

### 30. EKF-SLAM: linearize the models

One Gaussian estimates robot pose and every landmark together. Visual: equations. Timing: 1.5 minutes.

Joint state dimension is3+2J for planar pose and J landmarks. Static map portions of f leave landmarks unchanged, with zero map process noise. F and H are Jacobians of nonlinear f and h at the current prediction. Reuse S=H Sigma-bar H-transpose+C_z and K equations. Range h_j=sqrt((m_jx-x)^2+(m_jy-y)^2) is nonlinear. For nonzero range rho, its derivatives with respect to x,y are negative normalized displacement and with respect to landmark coordinates positive normalized displacement; derivative with respect to heading is zero for pure range. EKF approximates, rather than exactly representing ring ambiguity. Range-only landmark initialization needs suitable multi-view estimation, not an arbitrary point on the first circle.

`X = [x, y, θ, m_{1x}, m_{1y}, …]^T`

`μ̄ = f(μ,u);    Σ̄ = FΣF^T + Q`

`e = z − h(μ̄);    μ⁺ = μ̄ + Ke`

Jacobians approximate nonlinear motion and sensing.

Source: https://www-personal.acfr.usyd.edu.au/tbailey/papers/slamtute1.pdf

### 31. Why cross-covariance matters

A landmark observation can inform the robot and the rest of the map. Visual: covariance. Timing: 1 minutes.

Robot-map covariance Sigma_xm captures shared uncertainty; landmark-landmark blocks reflect common robot errors. Because Kalman gain uses the full joint covariance, observing one feature can update other correlated state components. Dropping cross blocks changes the inference and may produce overconfidence. A frame anchor does not remove all uncertainty. UKF propagates sigma points through nonlinear functions and also maintains a joint Gaussian representation; it does not automatically resolve severe multimodality. In the demo dependencies are represented through the mixture of maps conditional on sampled robot histories.

`Σ = [ Σ_{xx}   Σ_{xm} ;  Σ_{mx}   Σ_{mm} ]`

UKF uses sigma points; correlations still matter.

Source: https://www-personal.acfr.usyd.edu.au/tbailey/papers/slamtute1.pdf

### 32. Reconstruct the complete process

Different representations, the same estimation question. Visual: workflow. Timing: 1 minutes.

Have students narrate controls, prediction, observations, association, joint correction, and uncertainty representation. Ask what differs between selectors: known versus estimated landmark coordinates, not moving landmarks. Ask why robot resampling must carry the map and why one range cannot uniquely locate a feature. Conclude with selection of representation: particles/grids preserve ambiguity, EKF/UKF approximate Gaussian uncertainty, graph methods optimize constraints. SLAM is an estimation foundation used by planning but does not itself choose collision-free motions. Avoid universal accuracy or robustness claims.

Predict → observe → associate → update robot AND map.

Source: https://www-personal.acfr.usyd.edu.au/tbailey/papers/slamtute1.pdf

### 33. Questions & recap

Explain the evidence, the uncertainty, and what each mode estimates. Visual: recap. Timing: 3 minutes.

Three minutes. Check localization versus SLAM, known/static versus moving landmarks, motion versus observation updates, likelihood versus normalized weight, resampling without new evidence, ring ambiguity, carrying maps during resampling, and EKF/UKF alternatives. Distinguish landmark-location probability grids from occupancy maps. Connect to HW6 motion/measurement updates and occupancy mapping without inventing assignment interfaces or solutions. A correct answer should identify robot-map coupling and the limits of fixed-heading, known-ID range-only simulation. The initial pose prior anchors the frame imperfectly; absolute accuracy is not guaranteed.

Source: https://www-personal.acfr.usyd.edu.au/tbailey/papers/slamtute1.pdf

### 34. Joint posterior and reference frame

Conditional independence requires explicit assumptions. Visual: equations. Timing: 0 minutes.

The posterior factorization assumes Markov motion, static landmarks, known associations, conditionally independent observations, and independent landmark priors given the trajectory. Terms involving data are understood over available observations at each step. Conditional independence is not unconditional independence: mixing uncertain trajectories couples map variables. Without an initial pose/frame anchor, jointly translated configurations remain equivalent under relative ranging; additional rotational ambiguities depend on motion/frame information. Demo commands are given in fixed world axes and heading is held fixed, while initial position has a Gaussian prior. No absolute truth coordinates enter the SLAM estimator.

`p(x_{0:t},m | u,z,c) ∝ p(x_0)p(m)`

`  × ∏_k p(x_k | x_{k−1},u_k) ∏_j p(z_{k,j} | x_k,m_j)`

`p(m | x_{0:t},z,c) = ∏_j p(m_j | x_{0:t},z,c)`

Online marginals differ from a stored full-trajectory posterior.

Source: https://www-personal.acfr.usyd.edu.au/tbailey/papers/slamtute1.pdf

Source: https://www.cs.cmu.edu/~thrun/papers/montemerlo.fastslam-tr.pdf

### 35. Likelihoods and systematic selection

Stable arithmetic and correct ancestry preserve the model. Visual: equations. Timing: 0 minutes.

Independent Gaussian densities share constants in localization. Log-space normalization subtracts maximum then exponentiates; this is numerical stabilization rather than a new filter. For systematic resampling take k=0..N-1, cumulative weights, and the first cumulative value beyond each u_k. Expected copies are Nw_i though sample counts are correlated. Effective sample size is a useful degeneracy diagnostic; this demo does not use an adaptive threshold. In SLAM copy each ancestor position and all its conditional maps, with independent mutable storage for descendants. All-zero or invalid mass is an error; numerical underflow and impossible evidence must not be hidden with a uniform fallback.

`log L_i = const − ½ ∑_j ((z_j − h_j(p_i))/σ_z)²`

`u_k = (u_0 + k)/N;    u_0 ∼ Uniform(0,1)`

`N_{eff} = 1 / ∑_i w_{i}²`

Source: https://www.cs.cmu.edu/~thrun/papers/fox.aaai99.pdf

Source: https://www.cs.cmu.edu/~thrun/papers/montemerlo.fastslam-tr.pdf

### 36. Range-only conditional-map update

The evidence uses the previous map distribution. Visual: equations. Timing: 0 minutes.

This finite-grid update exactly normalizes each conditional discrete landmark distribution, apart from floating point. Robot inference remains a finite particle approximation and map coordinates are quantized. Evidence must integrate against the OLD map: using the newly conditioned map would reuse the same observation incorrectly. Gaussian density constants are included in recorded evidence; shared constants cancel across particle weights. After all measurements, normalize robot weights. Resample the complete particle/map pair. Conditional maps use float64; 500x3x6561 entries require about75.1MiB for persistent probabilities, with additional temporary/copy memory. Chunk32 particle batches limit likelihood temporaries. Uniform bounded grid priors imply boundary and resolution assumptions. First-range rings can be clipped by the prior; full marginal heatmaps expose this.

`e_{ij} = ∑_g L_{ij}(g) M_{old,ij}(g)`

`M_{new,ij}(g) = L_{ij}(g) M_{old,ij}(g) / e_{ij}`

`w_i⁺ ∝ w_i ∏_j e_{ij}`

`P(m_j=g | z,u) ≈ ∑_i w_i M_{ij}(g)`

Source: https://www.cs.cmu.edu/~thrun/papers/montemerlo.fastslam-tr.pdf

### 37. Kalman/EKF covariance and checks

Covariance correction must preserve the joint structure. Visual: equations. Timing: 0 minutes.

Joseph covariance form shown above is numerically robust; in exact arithmetic with the computed gain it agrees with (I-KH)Sigma-bar. At zero range the derivative is undefined. State and measurement dimensions must agree; full3+2J covariance includes all cross blocks. For scalar direct position example predicted variance.3664, gain.9421445102, posterior mean2.3913216765, variance.0211982515. Check Joseph and simplified forms numerically. This worked example is not the range-only demo. Range-only EKF initialization requires multiple observations or richer representations. UKF avoids explicit Jacobians but still approximates distributions with mean/covariance.

`Σ⁺ = (I − KH) Σ̄ (I − KH)^T + K C_z K^T`

`F = ∂f/∂X;    H = ∂h/∂X`

`ρ_j = ‖m_j − p‖;   ∂ρ/∂p = −(m_j − p)^T/ρ_j`

Source: https://www-personal.acfr.usyd.edu.au/tbailey/papers/slamtute1.pdf

### 38. Maps and graph-based SLAM

Landmark grids, occupancy cells, and factor graphs are different. Visual: equations. Timing: 0 minutes.

A landmark grid is a normalized distribution over one landmark location. Occupancy cells each carry a Bernoulli occupied/free variable; they are not normalized across the map. A graph objective sums weighted constraint residuals, with Omega information matrices. Pose anchors, robust losses, data association and sparsity are important; no graph optimizer is implemented here. For .5 occupancy prior and p_hit=.7, one update .7 and two updates49/58≈.8448276, subject to the inverse-model conditional assumptions. FastSLAM originally pairs trajectory particles with conditional landmark Kalman filters; our grid maps use the same decomposition idea without claiming identical implementation. Close with estimation versus planning and no universal best solver.

`Occupancy: ℓ⁺ = ℓ + logit(p_hit) − ℓ_0`

`Graph: minimize ∑_f r_f(X)^T Ω_f r_f(X)`

Source: https://www.cs.cmu.edu/~thrun/papers/thrun.iros01-occmap.pdf

Source: https://www.roboticsbook.org/S64_driving_perception.html

Source: https://www.cs.cmu.edu/~thrun/papers/montemerlo.fastslam-tr.pdf

## Demo and validation boundaries

Both modes use identified ranges only, fixed heading, 500 particles, 32 commands, unchanged sensor presets and simulation streams. SLAM uses three conditional81x81 landmark grids at0.125m spacing over[-2,8]m. These normalized location distributions are not occupancy grids. Grid bounds are priors, not walls. The estimator never receives true landmark positions; truth is an independent display overlay. Mode changes pause/reset while retaining seed/noise. Resampling copies complete robot/map hypotheses. There is no explicit loop-closure detector, pose-graph optimizer, moving-landmark model, or heading estimation.

All11 original files were read. No professor presentation was supplied. Preserve original teaching notes, requirements, five localization tests and four localization images using SHA-256. Validate Bayesian updates independently, test both complete noise runs, inspect new images, render/reopen PowerPoint, check38 slides/notes, five hidden backups34–38,38 PDF pages and exact45-minute total. Run results and versions are recorded separately from historical README validation; current Python3.13.5 uses NumPy2.2.6 rather than the preserved pinned1.26.4. Full human classroom rehearsal remains separate.