# Customer Churn Analysis — Telco Industry

## Business Problem
Sebuah perusahaan telekomunikasi mengalami churn rate tinggi.
Tim manajemen ingin mengetahui:
- Siapa customer yang paling berisiko churn?
- Faktor apa yang paling berpengaruh?
- Strategi retention apa yang efektif?

## Dataset
- **Source:** IBM Telco Customer Churn (Kaggle)
- **Size:** 7,043 customers × 21 features
- **Key Features:** tenure, contract type, monthly charges, payment method, churn status

## Tech Stack
| Tool           | Fungsi                       |
|----------------|------------------------------|
| Python (Colab) | Data cleaning & EDA          |
| SQL            | Segmentasi & aggregation     |
| Power BI       | Dashboard interaktif         |
| GitHub         | Version control & portfolio  |

## Project Structure
customer-churn-analysis/
├── data/
│   ├── raw/          # Dataset original
│   └── processed/    # Data setelah cleaning
├── notebooks/        # Jupyter/Colab notebook
├── sql/              # SQL queries
├── dashboard/        # File Power BI
├── assets/           # Chart exports
└── README.md

## Methodology
Business Understanding → Data Cleaning → EDA → Statistical Analysis → Dashboard → Recommendations

## Key Findings

### 1. Churn Rate Overall: 26.5%
> 1 dari 4 customer meninggalkan layanan — potensi revenue loss **$121,485/bulan**.

### 2. Tenure adalah Faktor Kritis
> 47.4% customer dengan tenure < 12 bulan churn — hampir 2x rata-rata keseluruhan.
> Masalah utama ada di fase onboarding, bukan customer lama.

### 3. Contract Type = Prediktor Terkuat
> Month-to-month: **42.7% churn rate**
> Two-year contract: **2.8% churn rate**
> Perbedaan 15x lipat antara dua segment ini.

### 4. Payment Method Berkorelasi dengan Churn
> Electronic check: **45.3%** — tertinggi dari semua metode pembayaran.
> Auto-payment (bank transfer/credit card): sekitar **15-17%**.

### 5. Value-Added Services Berperan Penting
> Customer tanpa OnlineSecurity: churn **41.8%** vs yang punya: **14.6%**
> Customer tanpa TechSupport: churn **41.6%** vs yang punya: **15.2%**

## Business Recommendations

| Prioritas | Strategi | Target | Impact |
|-----------|----------|--------|--------|
| 🔴 High | Early retention program 90 hari | Tenure < 12 bulan | Reduce early churn 10-15% |
| 🔴 High | Incentive upgrade ke annual contract | Month-to-month users | Reduce churn 20-30% |
| 🟡 Medium | Dorong auto-payment enrollment | Electronic check users | Reduce friction |
| 🟡 Medium | Bundle OnlineSecurity + TechSupport | New customers | Increase stickiness |