# Week 2 — Coordinate frames, transformations, and tf2

Mathematical reference sheet. Unless explicitly contrasted, formulas use **column vectors, right-handed rotations, Hamilton quaternions, fixed-axis XYZ roll–pitch–yaw**. Mathematical q is `(w,x,y,z)`; ROS fields are `(x,y,z,w)`. Units: metres and radians. XYZ formulas are not universal Euler formulas.

## Frames, direction, composition, inverse

A frame consists of an origin and three axes. A physical point has different coordinates in different frames. The pose of B in A, \({}^A T_B\), maps B coordinates into A:
\[
{}^A p={}^A R_B\,{}^B p+{}^A t_B,\qquad
{}^A T_B=\begin{bmatrix}{}^A R_B&{}^A t_B\\0&1\end{bmatrix}.
\]
The translation is B's origin in A. R's columns are B's axes in A; \(R^TR=I\), \(\det R=+1\). Orthogonality alone also permits reflections (det −1).
\[
\begin{bmatrix}p_A\\1\end{bmatrix}=T\begin{bmatrix}p_B\\1\end{bmatrix},\qquad
\begin{bmatrix}d_A\\0\end{bmatrix}=T\begin{bmatrix}d_B\\0\end{bmatrix}.
\]
Translation affects points, not free direction vectors. Six-component twists and wrenches require different transformation rules.
\[
{}^A T_C={}^A T_B{}^B T_C,\quad R_{AC}=R_{AB}R_{BC},\quad
t_{AC}=R_{AB}t_{BC}+t_{AB}.
\]
Rightmost acts first. From \(p_A=Rp_B+t\), subtract t and rotate back:
\[
p_B=R^T(p_A-t),\qquad T^{-1}=\begin{bmatrix}R^T&-R^Tt\\0&1\end{bmatrix}.
\]
Negating translation alone is generally incorrect.

## Elementary matrices and Euler angles

Here \(c_a=\cos a\), \(s_a=\sin a\):
\[
R_x(\phi)=\begin{bmatrix}1&0&0\\0&c_\phi&-s_\phi\\0&s_\phi&c_\phi\end{bmatrix},\quad
R_y(\theta)=\begin{bmatrix}c_\theta&0&s_\theta\\0&1&0\\-s_\theta&0&c_\theta\end{bmatrix},\quad
R_z(\psi)=\begin{bmatrix}c_\psi&-s_\psi&0\\s_\psi&c_\psi&0\\0&0&1\end{bmatrix}.
\]
Fixed XYZ: roll about original x, pitch about original y, yaw about original z. Thus:
First multiply the two rightmost factors:
\[
R_y(\theta)R_x(\phi)=\begin{bmatrix}
c_\theta&s_\theta s_\phi&s_\theta c_\phi\\
0&c_\phi&-s_\phi\\
-s_\theta&c_\theta s_\phi&c_\theta c_\phi
\end{bmatrix}.
\]
Premultiplying by Rz produces:
\[
R=R_z(\psi)R_y(\theta)R_x(\phi)=\begin{bmatrix}
c_\psi c_\theta&c_\psi s_\theta s_\phi-s_\psi c_\phi&c_\psi s_\theta c_\phi+s_\psi s_\phi\\
s_\psi c_\theta&s_\psi s_\theta s_\phi+c_\psi c_\phi&s_\psi s_\theta c_\phi-c_\psi s_\phi\\
-s_\theta&c_\theta s_\phi&c_\theta c_\phi
\end{bmatrix}.
\]
This equals intrinsic (moving-axis) ZYX with angles (ψ,θ,φ). Other sequences require their own products. At +90° each, \(R_zR_xe_x=e_y\), while \(R_xR_ze_x=e_z\): order matters.

### Recovering Euler angles

With entries \(r_{ij}\), outside gimbal lock:
\[
\theta=\operatorname{atan2}(-r_{31},\sqrt{r_{11}^2+r_{21}^2}),\quad
\phi=\operatorname{atan2}(r_{32},r_{33}),\quad
\psi=\operatorname{atan2}(r_{21},r_{11}).
\]
Choose θ∈[−π/2,π/2], φ,ψ∈(−π,π] with consistent endpoint handling. At cos θ≈0, choose:
\[
\phi=0,\quad\psi=\operatorname{atan2}(-r_{12},r_{22}),\quad
\theta=\operatorname{atan2}(-r_{31},\sqrt{r_{11}^2+r_{21}^2}).
\]
At +90° pitch only ψ−φ remains identifiable; at −90° only ψ+φ. Reconstruct R to check recovery; original angles cannot always be recovered. Gimbal lock is a coordinate singularity, not loss of physical rotation.

## Quaternion representation and algebra

For unit axis k and right-hand angle α:
\[
q=(w,v)=\left(\cos\frac\alpha2,k\sin\frac\alpha2\right),\qquad
w^2+x^2+y^2+z^2=1.
\]
Four entries subject to unit norm leave three orientation degrees of freedom. q and −q give the same rotation. Identity: mathematical (1,0,0,0), ROS (0,0,0,1). All-zero is invalid; normalize nonzero numerical input.

Hamilton multiplication:
\[
(w_1,v_1)\otimes(w_2,v_2)=(w_1w_2-v_1\cdot v_2,
w_1v_2+w_2v_1+v_1\times v_2).
\]
\[
\begin{aligned}
w&=w_1w_2-x_1x_2-y_1y_2-z_1z_2,\\
x&=w_1x_2+x_1w_2+y_1z_2-z_1y_2,\\
y&=w_1y_2-x_1z_2+y_1w_2+z_1x_2,\\
z&=w_1z_2+x_1y_2-y_1x_2+z_1w_2.
\end{aligned}
\]
Conjugate q*=(w,−v). General inverse q⁻¹=q*/‖q‖²; **unit** inverse is q*. Rotate a vector via pure quaternion P=(0,p), then translate separately:
\[
(0,p')=q\otimes(0,p)\otimes q^{-1},\qquad p_A=p'+t_{AB}.
\]
Quaternions encode orientation, not origin displacement. Composition: q_AC=q_AB⊗q_BC. If q₂=q_rel⊗q₁ in the same reference frame, q_rel=q₂⊗q₁⁻¹. Multiplication side matters.

### Unit quaternion to matrix (scalar-first Hamilton)
\[
R(q)=\begin{bmatrix}
1-2(y^2+z^2)&2(xy-wz)&2(xz+wy)\\
2(xy+wz)&1-2(x^2+z^2)&2(yz-wx)\\
2(xz-wy)&2(yz+wx)&1-2(x^2+y^2)
\end{bmatrix}.
\]

### Stable matrix to quaternion — all four branches

Validate SO(3) first. Compute:
\[
a_w=(1+r_{11}+r_{22}+r_{33})/4,\quad a_x=(1+r_{11}-r_{22}-r_{33})/4,
\]
\[
a_y=(1-r_{11}+r_{22}-r_{33})/4,\quad a_z=(1-r_{11}-r_{22}+r_{33})/4.
\]
Choose the largest candidate and its positive square root; clamp only tiny negative roundoff.

| Largest | Remaining components |
|---|---|
| w=√a_w | x=(r₃₂−r₂₃)/(4w), y=(r₁₃−r₃₁)/(4w), z=(r₂₁−r₁₂)/(4w) |
| x=√a_x | w=(r₃₂−r₂₃)/(4x), y=(r₁₂+r₂₁)/(4x), z=(r₁₃+r₃₁)/(4x) |
| y=√a_y | w=(r₁₃−r₃₁)/(4y), x=(r₁₂+r₂₁)/(4y), z=(r₂₃+r₃₂)/(4y) |
| z=√a_z | w=(r₂₁−r₁₂)/(4z), x=(r₁₃+r₃₁)/(4z), y=(r₂₃+r₃₂)/(4z) |

Normalize. Choosing the largest component avoids division by w≈0 near 180°. Invalid matrices should not be repaired by blindly clamping every candidate. Along a trajectory choose equivalent quaternion signs consistently.

### Fixed XYZ RPY to quaternion and back

**Only here**, c_φ=cos(φ/2), s_φ=sin(φ/2), similarly θ,ψ:
\[
\begin{aligned}
w&=c_\phi c_\theta c_\psi+s_\phi s_\theta s_\psi,\\
x&=s_\phi c_\theta c_\psi-c_\phi s_\theta s_\psi,\\
y&=c_\phi s_\theta c_\psi+s_\phi c_\theta s_\psi,\\
z&=c_\phi c_\theta s_\psi-s_\phi s_\theta c_\psi.
\end{aligned}
\]
Derive via q_z(ψ)⊗q_y(θ)⊗q_x(φ), where q_x=(c_φ,s_φ,0,0), q_y=(c_θ,0,s_θ,0), q_z=(c_ψ,0,0,s_ψ). Reverse: normalize q → R(q) → Euler extraction and singular branch above.

The intermediate product is
\[
q_y\otimes q_x=(c_\theta c_\phi,\ c_\theta s_\phi,\ s_\theta c_\phi,\ -s_\theta s_\phi).
\]
Left-multiply this by qz using the component multiplication formula to obtain the four half-angle expressions.

## Demo: one example, three representations

`camera_frame` is simplified, not optical. base_link→camera_mount has identity rotation and t=(0,0,0.5). camera_mount→camera_frame has zero translation and R_z(π/2).
\[
{}^{base}T_{camera}={}^{base}T_{mount}{}^{mount}T_{camera}
=\begin{bmatrix}0&-1&0&0\\1&0&0&0\\0&0&1&0.5\\0&0&0&1\end{bmatrix}.
\]
Camera p=(0.2,0,1). Matrix rotation gives (0,0.2,1); add (0,0,0.5) → base (0,0.2,1.5).

Euler: (φ,θ,ψ)=(0,0,π/2), so RzRyRx=Rz(π/2); same translation.

Quaternion: s=√2/2, math q=(s,0,0,s), ROS q=(0,0,s,s). With P=(0,0.2,0,1):
\[
q\otimes P=(-s,0.2s,0.2s,s),\qquad(q\otimes P)\otimes q^*=(0,0,0.2,1).
\]
Vector part=(0,0.2,1), then add translation. Inverse:
\[
p_A-t=(0,0.2,1),\quad R^T(p_A-t)=(0.2,0,1).
\]
Direct and composed transforms agree. For this z-only translation, −Rᵀt=(0,0,−0.5), but that simplification is not general.

### Mixed axes and special cases

For roll30°, pitch−20°, yaw45°, converted to radians:
\[
R\approx\begin{bmatrix}0.664463&-0.733295&0.144110\\0.664463&0.491450&-0.562997\\0.342020&0.469846&0.813798\end{bmatrix},
\quad q\approx(0.861642,0.299673,-0.057422,0.405550).
\]
For p=(1,2,3), Rp≈(−0.369798,−0.041628,3.723106). Add t=(0.4,−0.2,0.7): p'≈(0.030202,−0.241628,4.423106). Inverse recovers p; use unrounded numbers for verification.

At 180° about x, R=diag(1,−1,−1); squared candidates=(0,1,0,0), giving q=(0,1,0,0). Near 180° about normalized (1,2,3)/√14, z is largest; avoid a trace-only formula that divides by near-zero w.

At pitch+90°, roll30°/yaw45° gives the same R as roll0°/yaw15°. At pitch−90°, it matches roll0°/yaw75°. Check matrices, not uniqueness of Euler tuples.

## Changing conventions and ROS axes

Active rotation physically rotates a vector in a fixed basis: p'=Rp. Passive change of basis describes the same physical vector in rotated axes: if their orientation is R, the reverse coordinate map is Rᵀ. Define source/target before calling an operation active or passive.

Row convention: p'ᵀ=pᵀRᵀ+tᵀ; homogeneous row multiplication uses Tᵀ and reverses the product order upon transposition. For a basis conversion p_new=S p_old:
\[
R_{new}=SR_{old}S^{-1},\quad t_{new}=St_{old}.
\]
If source/target bases change differently: R_new=S_A R_old S_B⁻¹; t_new=S_A t_old. A handedness-changing reflection is not itself a unit-quaternion rotation.

ROS body axes: x forward, y left, z up. Optical: x right, y down, z forward. For aligned axes:
\[
p_{opt}=(-y_{body},-z_{body},x_{body})^T,\quad
S=\begin{bmatrix}0&-1&0\\0&0&-1\\1&0&0\end{bmatrix}.
\]
This is an axes-convention example, not an extra edge in the demo. REP 105 commonly uses map→odom→base_link: map is a long-term reference that can jump on correction; odom is continuous but drifts; base_link attaches to the robot. The demo's world is generic, not a localization implementation.

## tf2 and time interpolation

TransformStamped: header.frame_id=parent, child_frame_id=child; stored pose maps child coordinates into parent. `lookup_transform(target, source, time)` maps source→target. `Time()` requests latest common usable data, not necessarily now.

Static broadcasters publish `/tf_static` with transient-local durability; dynamic broadcasters publish `/tf`. Each listener fills its own buffer through executor callbacks. There is no central transform lookup server. Different nodes may own different edges; each child has one parent at a time. Avoid cycles, disconnected paths and conflicting publishers of one edge.

Use a transform at observation acquisition time. History is finite. Requests older than retained data or newer than available dynamic samples fail with extrapolation. Missing frames and disconnected trees also fail. Consistent clocks/use_sim_time matter. Bounded asynchronous waiting or retry can accommodate incoming samples; blocking the only executor callback can stop the listener filling the buffer.

For timestamps τ₀,τ₁ and τ between them:
\[
u=(\tau-\tau_0)/(\tau_1-\tau_0),\quad t(u)=(1-u)t_0+ut_1.
\]
Here t₀,t₁ are translation vectors, not timestamps. Unit q₀,q₁: if dot<0 replace q₁ by −q₁; clamp dot before acos. Ω=acos(q₀·q₁):
\[
\operatorname{SLERP}(q_0,q_1;u)=\frac{\sin((1-u)\Omega)}{\sin\Omega}q_0+
\frac{\sin(u\Omega)}{\sin\Omega}q_1.
\]
Near equality, normalize (1−u)q₀+uq₁ to avoid tiny denominator. For q₁=−q₀ flip its sign first: orientation remains constant. Check endpoints and unit norm. Interpolation approximates motion and does not authorize lookup outside retained bounds.

The demo camera→base chain is static, so latest lookup is valid there. `moving_base` adds world→base yaw=0.2·elapsed radians at 10 Hz. The synthetic target is fixed in camera coordinates and moves with the robot. `transform_point.py` restores the measurement stamp after `do_transform_point`, allowing both point messages to be converted into world by RViz at the same acquisition time. A genuinely delayed observation needs a timestamped lookup for its dynamic chain.

## Inspection and reproducible checks

```bash
ros2 run tf2_ros tf2_echo base_link camera_frame
ros2 run tf2_ros tf2_echo world base_link
ros2 topic info /tf_static
ros2 interface show geometry_msgs/msg/TransformStamped
```

RViz Fixed Frame begins at base_link, then world after moving_base starts. Different camera/base tuples overlap physically. Starting point_transformer before static_frames shows recoverable warnings; the timer returns and retries later. Follow the existing demo README for setup and commands.

Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File week02_tf/slides/validate_math.ps1` for independent numerical checks. Classroom ROS/RViz rehearsal is separate from artifact-generation validation.

## Sources and retained course reference

- [REP 103](https://github.com/ros-infrastructure/rep/blob/master/rep-0103.rst) and [REP 105](https://github.com/ros-infrastructure/rep/blob/master/rep-0105.rst).
- [Jazzy quaternion fundamentals](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Tf2/Quaternion-Fundamentals.html) and [tf2 tutorials](https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Tf2/Tf2-Main.html).
- tf2 implementation: [Matrix3x3](https://github.com/ros2/geometry2/blob/jazzy/tf2/include/tf2/LinearMath/Matrix3x3.hpp), [Quaternion](https://github.com/ros2/geometry2/blob/jazzy/tf2/include/tf2/LinearMath/Quaternion.hpp), [interpolation](https://github.com/ros2/geometry2/blob/jazzy/tf2/src/cache.cpp).
- Existing professor reference: separately supplied `Robotics_AutonomousSystems.pdf`, printed slides 12–22, 25–35, 37–40, and 43. Not found in this workspace; not reviewed.
