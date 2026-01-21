import tkinter as tk
from tkinter import messagebox

# Utility Warehouse rates (pence)
DAY_RATE_P = 40.42
NIGHT_RATE_P = 5.697
STANDING_CHARGE_P = 53.535

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
            #"=== Bill Breakdown ===\n"
            f"Day rate ({DAY_RATE_P}p)         : £{day_cost:.2f}\n"
            f"Night rate ({NIGHT_RATE_P}p)       : £{night_cost:.2f}\n"
            f"Standing charge ({STANDING_CHARGE_P}p) : £{standing_cost:.2f}\n"
            "-----------------------------------\n"
            f"Total cost                : £{total_cost:.2f}"
        )

        output_label.config(text=result_text)

    except ValueError:
        messagebox.showerror("Invalid Input", "Please enter valid numeric values.")


# --- GUI Setup ---
root = tk.Tk()
root.title("Electric Bill Calculator")
root.resizable(False, False)

frame = tk.Frame(root, padx=15, pady=15)
frame.pack()

tk.Label(frame, text="Electric Bill Calculator", font=("Arial", 14, "bold")).grid(
    row=0, column=0, columnspan=2, pady=10
)

# Inputs
tk.Label(frame, text="Day usage (kWh):").grid(row=1, column=0, sticky="e")
day_entry = tk.Entry(frame)
day_entry.grid(row=1, column=1)

# ✅ Set initial focus here
day_entry.focus_set()

tk.Label(frame, text="Night usage (kWh):").grid(row=2, column=0, sticky="e")
night_entry = tk.Entry(frame)
night_entry.grid(row=2, column=1)

tk.Label(frame, text="Standing charge days:").grid(row=3, column=0, sticky="e")
days_entry = tk.Entry(frame)
days_entry.grid(row=3, column=1)

# Button (Return key support)
calculate_button = tk.Button(frame, text="Calculate Bill", command=calculate_bill)
calculate_button.grid(row=4, column=0, columnspan=2, pady=10)

calculate_button.bind("<Return>", lambda event: calculate_bill())

# Output
output_label = tk.Label(frame, text="", justify="left", font=("Courier", 10))
output_label.grid(row=5, column=0, columnspan=2, pady=10)

root.mainloop()
