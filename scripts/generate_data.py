from pathlib import Path
import random

import numpy as np
import pandas as pd

# ============================================================
# CONFIG
# ============================================================

SEED = 42

random.seed(SEED)
np.random.seed(SEED)

ROOT = Path(__file__).resolve().parents[1]
RAW = ROOT / "data" / "raw"

N_CUSTOMERS = 2000
N_PRODUCTS = 300
N_ORDERS = 10000

FOLDERS = [
    "customers",
    "products",
    "orders",
    "order_items",
    "payments",
    "refunds",
    "deliveries",
    "marketing",
]

for folder in FOLDERS:
    (RAW / folder).mkdir(parents=True, exist_ok=True)


# ============================================================
# CUSTOMERS
# ============================================================

def generate_customers():
    cities = [
        "London",
        "Luton",
        "Manchester",
        "Birmingham",
        "Leeds",
        "Bristol",
    ]

    channels = [
        "Organic",
        "Google Ads",
        "Instagram",
        "Referral",
        "Email",
    ]

    customers = pd.DataFrame({
        "customer_id": [
            f"C{i:05d}"
            for i in range(1, N_CUSTOMERS + 1)
        ],

        "customer_name": [
            f"Customer_{i}"
            for i in range(1, N_CUSTOMERS + 1)
        ],

        "city": np.random.choice(
            cities,
            N_CUSTOMERS,
            p=[0.35, 0.10, 0.17, 0.15, 0.13, 0.10],
        ),

        "signup_date":
            pd.to_datetime("2025-01-01")
            + pd.to_timedelta(
                np.random.randint(0, 450, N_CUSTOMERS),
                unit="D",
            ),

        "acquisition_channel": np.random.choice(
            channels,
            N_CUSTOMERS,
            p=[0.30, 0.25, 0.20, 0.15, 0.10],
        ),
    })

    return customers


# ============================================================
# PRODUCTS
# ============================================================

def generate_products():
    categories = [
        "Electronics",
        "Sports",
        "Furniture",
        "Accessories",
        "Home",
    ]

    category = np.random.choice(
        categories,
        N_PRODUCTS,
        p=[0.25, 0.20, 0.15, 0.20, 0.20],
    )

    cost_price = []

    for cat in category:

        if cat == "Electronics":
            cost = np.random.randint(50, 500)

        elif cat == "Furniture":
            cost = np.random.randint(80, 400)

        elif cat == "Sports":
            cost = np.random.randint(20, 180)

        elif cat == "Accessories":
            cost = np.random.randint(5, 100)

        else:
            cost = np.random.randint(10, 200)

        cost_price.append(cost)

    cost_price = np.array(cost_price)

    margin_multiplier = np.random.uniform(
        1.20,
        2.00,
        N_PRODUCTS,
    )

    selling_price = np.round(
        cost_price * margin_multiplier,
        2,
    )

    products = pd.DataFrame({
        "product_id": [
            f"P{i:04d}"
            for i in range(1, N_PRODUCTS + 1)
        ],

        "product_name": [
            f"Product_{i}"
            for i in range(1, N_PRODUCTS + 1)
        ],

        "category": category,

        "selling_price": selling_price,

        "cost_price": cost_price,
    })

    return products


# ============================================================
# ORDERS
# ============================================================

def generate_orders(customers):
    orders = []

    customer_ids = customers["customer_id"].tolist()

    signup_lookup = customers.set_index(
        "customer_id"
    )["signup_date"].to_dict()

    for i in range(1, N_ORDERS + 1):

        customer_id = np.random.choice(customer_ids)

        signup_date = signup_lookup[customer_id]

        max_date = pd.Timestamp("2026-08-20")

        days_available = max(
            (max_date - signup_date).days,
            1,
        )

        order_date = (
            signup_date
            + pd.Timedelta(
                days=np.random.randint(0, days_available + 1)
            )
        )

        discount = np.random.choice(
            [0, 5, 10, 15, 20, 30],
            p=[0.35, 0.20, 0.18, 0.12, 0.10, 0.05],
        )

        status = np.random.choice(
            ["Completed", "Cancelled"],
            p=[0.94, 0.06],
        )

        orders.append({
            "order_id": f"O{i:06d}",
            "customer_id": customer_id,
            "order_date": order_date,
            "status": status,
            "discount_amount": discount,
        })

    return pd.DataFrame(orders)


# ============================================================
# ORDER ITEMS
# ============================================================

def generate_order_items(orders, products):
    rows = []

    item_id = 1

    product_ids = products["product_id"].tolist()

    for order_id in orders["order_id"]:

        number_of_items = np.random.choice(
            [1, 2, 3, 4],
            p=[0.35, 0.35, 0.20, 0.10],
        )

        chosen_products = np.random.choice(
            product_ids,
            number_of_items,
            replace=False,
        )

        for product_id in chosen_products:

            rows.append({
                "order_item_id":
                    f"OI{item_id:07d}",

                "order_id":
                    order_id,

                "product_id":
                    product_id,

                "quantity":
                    np.random.choice(
                        [1, 2, 3],
                        p=[0.72, 0.20, 0.08],
                    ),
            })

            item_id += 1

    return pd.DataFrame(rows)


# ============================================================
# DELIVERIES
# ============================================================

def generate_deliveries(orders):
    rows = []

    completed_orders = orders[
        orders["status"] == "Completed"
    ]

    for _, order in completed_orders.iterrows():

        order_date = pd.Timestamp(order["order_date"])

        promised_days = np.random.choice(
            [2, 3, 4, 5],
            p=[0.15, 0.45, 0.30, 0.10],
        )

        promised_date = (
            order_date
            + pd.Timedelta(days=int(promised_days))
        )

        # Most deliveries are on time,
        # but some are intentionally late.
        if np.random.random() < 0.18:
            delay_days = np.random.randint(1, 8)
        else:
            delay_days = np.random.choice(
                [-1, 0],
                p=[0.15, 0.85],
            )

        delivery_date = (
            promised_date
            + pd.Timedelta(days=int(delay_days))
        )

        delivery_status = (
            "Late"
            if delay_days > 0
            else "On Time"
        )

        rows.append({
            "delivery_id":
                f"D{len(rows)+1:06d}",

            "order_id":
                order["order_id"],

            "promised_date":
                promised_date,

            "delivery_date":
                delivery_date,

            "delay_days":
                max(delay_days, 0),

            "delivery_status":
                delivery_status,
        })

    return pd.DataFrame(rows)


# ============================================================
# PAYMENTS
# ============================================================

def generate_payments(orders, order_items, products):
    merged = (
        order_items
        .merge(
            products[
                [
                    "product_id",
                    "selling_price",
                ]
            ],
            on="product_id",
        )
    )

    merged["line_revenue"] = (
        merged["selling_price"]
        * merged["quantity"]
    )

    totals = (
        merged
        .groupby("order_id")["line_revenue"]
        .sum()
        .reset_index()
    )

    order_values = (
        orders
        .merge(totals, on="order_id", how="left")
    )

    order_values["line_revenue"] = (
        order_values["line_revenue"]
        .fillna(0)
    )

    order_values["payment_amount"] = (
        order_values["line_revenue"]
        - order_values["discount_amount"]
    ).clip(lower=0)

    methods = [
        "Card",
        "PayPal",
        "Apple Pay",
        "Google Pay",
    ]

    rows = []

    for _, order in order_values.iterrows():

        method = np.random.choice(
            methods,
            p=[0.50, 0.20, 0.18, 0.12],
        )

        if order["status"] == "Cancelled":
            payment_status = np.random.choice(
                ["Failed", "Refunded"],
                p=[0.70, 0.30],
            )
        else:
            payment_status = np.random.choice(
                ["Paid", "Failed"],
                p=[0.985, 0.015],
            )

        rows.append({
            "payment_id":
                f"PAY{len(rows)+1:06d}",

            "order_id":
                order["order_id"],

            "payment_method":
                method,

            "payment_amount":
                round(
                    float(order["payment_amount"]),
                    2,
                ),

            "payment_status":
                payment_status,
        })

    return pd.DataFrame(rows)


# ============================================================
# REFUNDS
# ============================================================

def generate_refunds(
    orders,
    deliveries,
    payments,
):
    rows = []

    delivery_lookup = (
        deliveries
        .set_index("order_id")
        .to_dict("index")
    )

    payment_lookup = (
        payments
        .set_index("order_id")
        .to_dict("index")
    )

    completed_orders = orders[
        orders["status"] == "Completed"
    ]

    reasons = [
        "Damaged Item",
        "Wrong Item",
        "Late Delivery",
        "Changed Mind",
        "Product Quality",
    ]

    for _, order in completed_orders.iterrows():

        order_id = order["order_id"]

        if order_id not in delivery_lookup:
            continue

        if order_id not in payment_lookup:
            continue

        delivery = delivery_lookup[order_id]

        payment = payment_lookup[order_id]

        refund_probability = 0.05

        # Business rule:
        # late delivery increases refund risk.
        if delivery["delay_days"] > 0:
            refund_probability += 0.12

        if delivery["delay_days"] >= 4:
            refund_probability += 0.10

        # Large discounts slightly increase
        # return/refund behaviour.
        if order["discount_amount"] >= 20:
            refund_probability += 0.04

        if np.random.random() < refund_probability:

            if delivery["delay_days"] > 0:
                reason = np.random.choice(
                    reasons,
                    p=[
                        0.15,
                        0.10,
                        0.45,
                        0.10,
                        0.20,
                    ],
                )
            else:
                reason = np.random.choice(
                    reasons,
                    p=[
                        0.25,
                        0.15,
                        0.05,
                        0.25,
                        0.30,
                    ],
                )

            refund_percentage = np.random.choice(
                [0.25, 0.50, 1.00],
                p=[0.20, 0.25, 0.55],
            )

            refund_amount = (
                float(payment["payment_amount"])
                * refund_percentage
            )

            rows.append({
                "refund_id":
                    f"R{len(rows)+1:06d}",

                "order_id":
                    order_id,

                "refund_date":
                    pd.Timestamp(
                        delivery["delivery_date"]
                    )
                    + pd.Timedelta(
                        days=np.random.randint(1, 15)
                    ),

                "refund_amount":
                    round(refund_amount, 2),

                "refund_reason":
                    reason,
            })

    return pd.DataFrame(rows)


# ============================================================
# MARKETING
# ============================================================

def generate_marketing(customers):
    channel_settings = {
        "Organic": {
            "monthly_spend": 1500,
            "cac": 8,
        },

        "Google Ads": {
            "monthly_spend": 18000,
            "cac": 42,
        },

        "Instagram": {
            "monthly_spend": 14000,
            "cac": 55,
        },

        "Referral": {
            "monthly_spend": 5000,
            "cac": 18,
        },

        "Email": {
            "monthly_spend": 3500,
            "cac": 12,
        },
    }

    months = pd.date_range(
        "2025-01-01",
        "2026-08-01",
        freq="MS",
    )

    rows = []

    record_id = 1

    for month in months:

        for channel, config in channel_settings.items():

            base_spend = config["monthly_spend"]

            spend = base_spend * np.random.uniform(
                0.85,
                1.15,
            )

            base_cac = config["cac"]

            cac = base_cac * np.random.uniform(
                0.90,
                1.15,
            )

            acquired_customers = max(
                int(spend / cac),
                1,
            )

            # Intentional pattern:
            # Instagram has higher spend/CAC
            # than most other channels.
            rows.append({
                "marketing_id":
                    f"M{record_id:05d}",

                "month":
                    month,

                "channel":
                    channel,

                "marketing_spend":
                    round(spend, 2),

                "customers_acquired":
                    acquired_customers,

                "customer_acquisition_cost":
                    round(
                        spend / acquired_customers,
                        2,
                    ),
            })

            record_id += 1

    return pd.DataFrame(rows)


# ============================================================
# SAVE
# ============================================================

def save_data(
    customers,
    products,
    orders,
    order_items,
    payments,
    refunds,
    deliveries,
    marketing,
):

    datasets = {
        "customers": customers,
        "products": products,
        "orders": orders,
        "order_items": order_items,
        "payments": payments,
        "refunds": refunds,
        "deliveries": deliveries,
        "marketing": marketing,
    }

    for name, dataframe in datasets.items():

        path = (
            RAW
            / name
            / f"{name}.csv"
        )

        dataframe.to_csv(
            path,
            index=False,
        )


# ============================================================
# MAIN
# ============================================================

def main():

    print("Generating ProfitGuard dataset...\n")

    customers = generate_customers()

    products = generate_products()

    orders = generate_orders(
        customers
    )

    order_items = generate_order_items(
        orders,
        products,
    )

    deliveries = generate_deliveries(
        orders
    )

    payments = generate_payments(
        orders,
        order_items,
        products,
    )

    refunds = generate_refunds(
        orders,
        deliveries,
        payments,
    )

    marketing = generate_marketing(
        customers
    )

    save_data(
        customers,
        products,
        orders,
        order_items,
        payments,
        refunds,
        deliveries,
        marketing,
    )

    print("Generated successfully:\n")

    print(f"customers     : {len(customers):,}")
    print(f"products      : {len(products):,}")
    print(f"orders        : {len(orders):,}")
    print(f"order_items   : {len(order_items):,}")
    print(f"payments      : {len(payments):,}")
    print(f"refunds       : {len(refunds):,}")
    print(f"deliveries    : {len(deliveries):,}")
    print(f"marketing     : {len(marketing):,}")


if __name__ == "__main__":
    main()