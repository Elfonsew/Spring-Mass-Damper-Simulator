Project Overview

The Spring Mass Damper Simulator is an interactive MATLAB application designed to simulate 
the dynamics of a mass-spring-damper system. The simulator enables users to manipulate system parameters such 
as mass, spring constant, and damping coefficient. Additionally, it allows control inputs via a Bluetooth-connected 
game controller, specifically the R2 button, to simulate displacing the mass from an equilibrium position. This project aims to provide a real-time
visualization of the system’s harmonic response, adjusting the parameters for a realistic simulation experience.

Requirements

	•	MATLAB (version supporting vrjoystick and graphical interface commands)
	•	Bluetooth-enabled game controller (e.g., PS5 controller)
	•	Windows or macOS with Bluetooth support
	•	Basic knowledge of mass-spring-damper dynamics

Usage Instructions

Running the Simulator

	1.	Open MATLAB and ensure that all required packages (such as the vrjoystick package) are installed and your game controller is connected via Bluetooth.
	2.	Run the script by executing the Spring Mass Damper Simulator code.
	3.	The application will launch a graphical user interface (GUI) with adjustable parameters and a live plot for position tracking.

Adjustable Parameters

The simulator allows you to modify the following parameters through the GUI:

	•	Mass (m): The mass of the system in kilograms (kg).
	•	Spring Coefficient (k): The spring constant in Newtons per meter (N/m).
	•	Damping Coefficient (c): The damping coefficient in Newton-seconds per meter (Ns/m).
	•	R2 Distance: Maximum displacement distance when the R2 button is fully pressed, in meters (m).
	•	Time Window: Duration of the plot window in seconds (s).
	•	Time Scale: Ratio of simulation time to real-time, which affects the simulation’s speed.

These parameters can be adjusted in real time, and changes will immediately reflect in the simulation.

Controls

	•	R2 Button (Trigger): Pressing R2 simulates a displacement of the mass.
	•	L2 Button (Trigger): Resets the simulation state.
	•	L3 Button (Press Joystick): Terminates the simulation and exits the application.

Simulation Information

The simulator computes several key variables, including:

	•	Damping Ratio (ζ): Displays whether the system is underdamped, critically damped, or overdamped.
	•	Natural Frequency (ωₙ): Represents the system’s natural oscillation frequency.
	•	Damping Coefficient (c_c): Represents the critical damping coefficient to avoid oscillations.

These variables are calculated based on user-defined values of mass (m), spring constant (k), and damping coefficient (c) and are displayed on the GUI for reference.

Plotting Dynamics

The plot dynamically updates based on the real-time position of the mass as it responds to the simulated input. The plot shows the position of the mass over time, 
allowing users to observe the effects of different damping ratios and parameter configurations.

Additional Notes

	•	Sampling Rate: The simulation adapts its sampling rate based on the theoretical max rate tested at initialization.
	•	Performance: High values of k (spring constant) may cause aliasing, especially if the computer’s processing speed is limited. Adjust the tScale parameter to compensate.
	•	Termination: The simulation can be terminated at any time using the L3 button on the controller.

Example Use Case

	1.	Set the mass (m) to 1 kg, spring coefficient (k) to 1 N/m, and damping coefficient (c) to 1 Ns/m.
	2.	Adjust the time window and scale for desired simulation speed.
	3.	Press the R2 button on your controller to displace the mass and observe the position response.
	4.	Adjust parameters as desired to visualize different damping states and dynamic behaviors.

Troubleshooting

	•	Controller Not Recognized: Ensure the controller is connected via Bluetooth and recognized by MATLAB’s vrjoystick function.
	•	Slow Response: Lower the time scale (tScale) or adjust the spring constant (k) for smoother visualization.
	•	Aliasing in High k/m Ratios: Lower the time scale if the simulation appears unstable or aliased.

This README provides guidance on setting up, using, and troubleshooting the Spring Mass Damper Simulator, allowing users to explore mechanical dynamics interactively.
