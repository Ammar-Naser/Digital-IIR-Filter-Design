# Digital-IIR-Filter-Design
The project involves the design of a First-Order Digital Infinite Impulse Response (IIR) Filter, which is a widely used type of filter in digital signal processing for applications like audio enhancement, communications, and control systems. This filter operates with a recursive feedback loop, where the output depends on the current and previous input samples as well as previous output samples. Key challenges in IIR filter design include managing stability and phase distortion due to feedback.

# Key Verilog Specifications:
-Filter Inputs and Coefficients: 4-bit signed numbers using 2's complement and sign extension.
-Internal Adder/Registers: 8-bit width, with overflow wrapping (no saturation).
-Feedback Logic: Implements the equation: 𝑦[𝑛] = 𝑏0 𝑥[𝑛] + 𝑏1 𝑥[𝑛 − 1] + 𝑎1 𝑦[𝑛 − 1]
-Special Consideration:
    The feedback term 𝑎1 𝑦[𝑛 − 1] will generate 12 bits; the 4 least significant bits are truncated.
    Active-low asynchronous Reset is required for all registers to clear the feedback loop.

# Verification & Test Cases:
Case 1: Low-Pass Filter
• Coefficients: Set b0 = 3, b1 = 0, a1 = 4 (Positive Feedback). 
• Input: Apply a step signal where x[n] changes from 0 to 5.

Case 2: High-Pass Filter
• Coefficients: Set b0 = 2, b1 = -2, a1 = -4 (Negative Feedback). 
• Input: Apply a step signal where x[n] changes from 0 to 5.

Case 3: Impulse Response
• Coefficients: Set b0 = 3, b1 = 3, a1 = 7 (High Gain). 
• Input: Apply a single pulse: x[0] = 5, then x[n] = 0 for all n > 0.

Case 4: Smoothing rapid changes
• Coefficients: Set b0 =1, b1 =1, a1 =4 
• Input: Toggle x[n] between 2 and 6 every clock cycle (2,6,2,6…).

Case 5: Overflow Failure
• Coefficients: Set b0 =7, b1 =7, a1 =6. 
• Input: Apply a step signal where x[n] changes from 0 to 7.
