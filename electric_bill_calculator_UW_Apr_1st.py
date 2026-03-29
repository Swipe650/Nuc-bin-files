import tkinter as tk
from tkinter import messagebox

# Utility Warehouse rates (pence) Fixed Start 80 1/4/26 - 31/3/27
DAY_RATE_P = 36.621
NIGHT_RATE_P = 6.916
STANDING_CHARGE_P = 56.972

# Convert to pounds
DAY_RATE = DAY_RATE_P / 100
NIGHT_RATE = NIGHT_RATE_P / 100
STANDING_CHARGE = STANDING_CHARGE_P / 100


def calculate_bill():
    try:
        day_usage = float(day_entry.get())
        night_usage = float(night_entry.get())
        num_days = int(days_entry.get())

        day_cost = DAY_RATE * day_usage
        night_cost = NIGHT_RATE * night_usage
        standing_cost = STANDING_CHARGE * num_days
        total_cost = day_cost + night_cost + standing_cost

        result_text = (
            f"Day rate ({DAY_RATE_P}p)        : £{day_cost:.2f}\n"
            f"Night rate ({NIGHT_RATE_P}p)       : £{night_cost:.2f}\n"
            f"Standing charge ({STANDING_CHARGE_P}p) : £{standing_cost:.2f}\n"
            "-----------------------------------\n"
            f"Total cost                : £{total_cost:.2f}"
        )

        output_label.config(text=result_text)

    except ValueError:
        messagebox.showerror("Invalid Input", "Please enter valid numeric values.")


def clear_fields():
    """Clear all input fields and reset the output display"""
    day_entry.delete(0, tk.END)
    night_entry.delete(0, tk.END)
    days_entry.delete(0, tk.END)
    output_label.config(text="")
    day_entry.focus_set()  # Set focus back to day entry for convenience


# --- GUI Setup ---
root = tk.Tk()
root.title("Electric Bill Calculator")
root.resizable(False, False)

frame = tk.Frame(root, padx=15, pady=15)
frame.pack()

tk.Label(frame, text="UW Fixed Start 80 Calculator", font=("Arial", 14, "bold")).grid(
    row=0, column=0, columnspan=3, pady=10
)

# Inputs
tk.Label(frame, text="Day usage (kWh):").grid(row=1, column=0, sticky="e")
day_entry = tk.Entry(frame)
day_entry.grid(row=1, column=1, columnspan=2, sticky="w")

# Set initial focus here
day_entry.focus_set()

tk.Label(frame, text="Night usage (kWh):").grid(row=2, column=0, sticky="e")
night_entry = tk.Entry(frame)
night_entry.grid(row=2, column=1, columnspan=2, sticky="w")

tk.Label(frame, text="Standing charge days:").grid(row=3, column=0, sticky="e")
days_entry = tk.Entry(frame)
days_entry.grid(row=3, column=1, columnspan=2, sticky="w")

# Button frame for better layout
button_frame = tk.Frame(frame)
button_frame.grid(row=4, column=0, columnspan=3, pady=10)

# Calculate button
calculate_button = tk.Button(button_frame, text="Calculate", command=calculate_bill)
calculate_button.pack(side=tk.LEFT, padx=5)

# Reset button (no color)
reset_button = tk.Button(button_frame, text="Reset", command=clear_fields)
reset_button.pack(side=tk.LEFT, padx=5)

# Bind Enter key to calculate
calculate_button.bind("<Return>", lambda event: calculate_bill())
root.bind("<Return>", lambda event: calculate_bill())

# Output
output_label = tk.Label(frame, text="", justify="left", font=("Courier", 10))
output_label.grid(row=5, column=0, columnspan=3, pady=10)

root.mainloop()
