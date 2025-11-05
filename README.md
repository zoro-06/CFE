# (Continued Fraction Expansion)CFE: The Math-to-Circuit Translator ⚡

Ever looked at a complex math equation (like a polynomial) and thought, "You know what this needs? To be a *circuit*."

No? Just me?

Well, in Electrical Engineering, that's a real problem. We often have a big, scary formula that describes exactly how we *want* a filter or network to behave. But how do you *build* it? What resistors? What capacitors?

This project is a tool to solve that problem. It's a simple Octave script that automates **Continued Fraction Expansion (CFE)**, a classic (and, let's be honest, tedious) technique to turn a scary math function into a simple "shopping list" of components.

## 💡 The Big Idea

Imagine you have a mathematical "recipe" for a filter, like:

$$
Z(s) = \frac{s^3 + 2s^2 + 3s + 1}{s^2 + s + 1}
$$

How do you build that? You can't just go to the store and buy a "$s^3$".

This script takes that function and breaks it down, piece by piece, by repeatedly dividing and flipping the formula. With each step, it "pulls out" one component from the circuit.



The final result is a simple list of component values for a **ladder network**, which is a circuit that looks like... well, a ladder.

## 🚀 How to Use

This is an Octave script (`.m` file). You'll need [Octave](https://octave.org/) installed to run it.

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/zoro-06/cfe-automation.git](https://github.com/zoro-06/cfe-automation.git)
    cd cfe-automation
    ```

2.  **Open Octave** in that directory.

3.  **Define your polynomials:**
    In the Octave command window, create your numerator and denominator polynomials. In Octave, polynomials are just vectors of their coefficients, from highest power to lowest.

    For our example, `s^3 + 2s^2 + 3s + 1` becomes `[1, 2, 3, 1]`
    And `s^2 + s + 1` becomes `[1, 1, 1]`

4.  **Run the script:**
    ```octave
    >> num = [1, 2, 3, 1]
    >> den = [1, 1, 1]
    >> cfe_script(num, den)
    ```

## Example Output

Running the script on our example function will spit out the component "shopping list":
