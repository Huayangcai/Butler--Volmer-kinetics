# Golden Competition States in Butler-Volmer Kinetics

This repository contains a MATLAB script for the three core figures of the Golden competition-state formulation of complementary-coefficient Butler-Volmer kinetics.

The script generates three publication-style figures and exports them as PDF and PNG files.

---

## 1. MATLAB script

```text
three_core_theory_figures.m
```

Recommended environment:

- MATLAB R2020a or later
- No additional toolbox is required

Run:

```matlab
three_core_theory_figures
```

---

## 2. Butler-Volmer equation

The overpotential is

$$
\eta = E - E_{eq}
$$

The dimensionless overpotential is

$$
u = \frac{F\eta}{RT}
$$

The complementary-coefficient Butler-Volmer equation is

$$
j = j_0 [e^{(1-a)u} - e^{-au}]
$$

where $j$ is the current density, $j_0$ is the exchange current density, and $a$ is the cathodic transfer coefficient.

The model interval is

$$
0 \le a \le 1
$$

---

## 3. Dual-channel representation

Define the positive anodic and cathodic channel magnitudes:

$$
J_+ = j_0 e^{(1-a)u}
$$

$$
J_- = j_0 e^{-au}
$$

Define

$$
S = J_+ - J_-
$$

$$
N = J_+ + J_-
$$

$$
M = 2\sqrt{J_+J_-}
$$

The competition coordinate is

$$
\xi = \frac{1}{2}\ln\frac{J_+}{J_-}
$$

For complementary-coefficient Butler-Volmer kinetics,

$$
\xi = \frac{u}{2}
$$

and

$$
M = 2j_0 e^{(1-2a)u/2}
$$

Thus, transfer-coefficient asymmetry changes the dimensional current scale but does not change the relation between $u$ and $\xi$.

---

## 4. Normalized competition geometry

Define

$$
\beta = \frac{S}{N}
$$

and

$$
m = \frac{M}{N}
$$

Then

$$
\beta = \tanh\xi
$$

and

$$
m = \frac{1}{\cosh\xi}
$$

Therefore,

$$
\beta^2 + m^2 = 1
$$

This relation gives the upper unit semicircle shown in Figure 1.

---

## 5. Golden competition state

The Golden ratio is

$$
\phi = \frac{1+\sqrt{5}}{2}
$$

Let $s$ denote the polarization branch:

- $s=+1$ for positive overpotential
- $s=-1$ for negative overpotential

The signed Golden overpotential is

$$
u_\phi = 2s\ln\phi
$$

Since

$$
\xi = \frac{u}{2}
$$

the Golden competition coordinate is

$$
\xi_\phi = s\ln\phi
$$

The corresponding normalized state is

$$
\beta_\phi = \frac{s}{\sqrt{5}}
$$

$$
m_\phi = \frac{2}{\sqrt{5}}
$$

Therefore,

$$
(\beta_\phi,m_\phi)
=
(\pm\frac{1}{\sqrt{5}},\frac{2}{\sqrt{5}})
$$

Numerically,

$$
\beta_\phi \approx \pm 0.447
$$

$$
m_\phi \approx 0.894
$$

The Golden state is therefore invariant in normalized competition space.

---

## 6. Figure 1

Figure 1 shows

$$
\beta^2 + m^2 = 1
$$

and the two Golden states

$$
(-\frac{1}{\sqrt{5}},\frac{2}{\sqrt{5}})
$$

and

$$
(\frac{1}{\sqrt{5}},\frac{2}{\sqrt{5}})
$$

Generated files:

```text
Fig1_ReferencePointInnovation.pdf
Fig1_ReferencePointInnovation.png
```

---

## 7. Asymmetric Golden current

At the signed Golden overpotential, the exact current relation is

$$
\frac{|j_\phi|}{j_0}
=
\phi^{s(1-2a)}
$$

For symmetric Butler-Volmer kinetics,

$$
a = \frac{1}{2}
$$

and therefore

$$
|j_\phi| = j_0
$$

When $a$ differs from $1/2$, the normalized Golden state remains unchanged, but the current magnitude changes.

---

## 8. Exact correction

The corrected exchange-current estimate is

$$
j_{0,corr}
=
|j_\phi|\phi^{s(2a-1)}
$$

Within the complementary-coefficient Butler-Volmer model,

$$
\frac{j_{0,corr}}{j_0} = 1
$$

for

$$
0 \le a \le 1
$$

and for both polarization branches.

---

## 9. Figure 2

For the positive branch, $s=+1$:

$$
\frac{|j_\phi|}{j_0}
=
\phi^{1-2a}
$$

For the negative branch, $s=-1$:

$$
\frac{|j_\phi|}{j_0}
=
\phi^{2a-1}
$$

After correction,

$$
\frac{j_{0,corr}}{j_0} = 1
$$

Generated files:

```text
Fig2_KineticGeneralization.pdf
Fig2_KineticGeneralization.png
```

---

## 10. Butler-Volmer admissibility window

Define the required correction factor

$$
C_{req}
=
\frac{j_{0,ref}}{|j_\phi|}
$$

If the difference can be explained only by transfer-coefficient asymmetry,

$$
C_{req}
=
\phi^{s(2a_{req}-1)}
$$

Therefore,

$$
a_{req}
=
\frac{1}{2}
[1+s\frac{\ln C_{req}}{\ln\phi}]
$$

The condition

$$
0 \le a_{req} \le 1
$$

gives

$$
\frac{1}{\phi}
\le
C_{req}
\le
\phi
$$

Numerically,

$$
0.618
\le
C_{req}
\le
1.618
$$

A value outside this interval cannot be explained by transfer-coefficient asymmetry alone within this model.

---

## 11. Figure 3

The HER data are evaluated on the cathodic Golden branch:

$$
s = -1
$$

For each metal,

$$
C_{req}
=
\frac{j_{0,ref}}{|j_\phi|}
$$

and

$$
a_{req}
=
\frac{1}{2}
[1-\frac{\ln C_{req}}{\ln\phi}]
$$

The script contains data for:

```text
Pd, Pt, Rh, Ir, Co, Re, Ru, Ni, Ag
```

Pd, Pt, Rh, and Ir are inside the complementary-BV admissibility window.

Co, Re, Ru, Ni, and Ag are below the lower bound

$$
\frac{1}{\phi}
$$

Generated files:

```text
Fig3_BVAdmissibilityWindow.pdf
Fig3_BVAdmissibilityWindow.png
```

---

## 12. Core equations

$$
u = \frac{F\eta}{RT}
$$

$$
j = j_0 [e^{(1-a)u} - e^{-au}]
$$

$$
\xi = \frac{u}{2}
$$

$$
\beta = \tanh\xi
$$

$$
m = \frac{1}{\cosh\xi}
$$

$$
\beta^2 + m^2 = 1
$$

$$
u_\phi = 2s\ln\phi
$$

$$
\beta_\phi = \frac{s}{\sqrt{5}}
$$

$$
m_\phi = \frac{2}{\sqrt{5}}
$$

$$
\frac{|j_\phi|}{j_0}
=
\phi^{s(1-2a)}
$$

$$
j_{0,corr}
=
|j_\phi|\phi^{s(2a-1)}
$$

$$
C_{req}
=
\frac{j_{0,ref}}{|j_\phi|}
$$

$$
a_{req}
=
\frac{1}{2}
[1+s\frac{\ln C_{req}}{\ln\phi}]
$$

$$
\frac{1}{\phi}
\le
C_{req}
\le
\phi
$$

---

## 13. GitHub math formatting

This README intentionally uses only simple LaTeX commands.

Avoid commands such as:

```text
\operatorname
\mathcal
\mathrm
\text
```

For example, instead of writing

```text
m = \operatorname{sech}\xi
```

this README uses

$$
m = \frac{1}{\cosh\xi}
$$

Display equations are placed on separate lines using `$$`.

Inline variables use `$...$`.

---

## 14. Repository structure

```text
.
├── README.md
├── three_core_theory_figures.m
├── Fig1_ReferencePointInnovation.pdf
├── Fig1_ReferencePointInnovation.png
├── Fig2_KineticGeneralization.pdf
├── Fig2_KineticGeneralization.png
├── Fig3_BVAdmissibilityWindow.pdf
└── Fig3_BVAdmissibilityWindow.png
```
