# 🏦 Banking System Database

A relational database system designed to manage core banking operations, including customers, accounts, transactions, loans, branches, and employees.
It simulates a Core Banking Solution (CBS) with data integrity, triggers, analytics & reporting.

## 📑 Table of Contents  

- ✨ [Features](#-features)  
- 🗂 [Database Schema](#-database-schema)  
- ⚙️ [Stored Procedures](#️-stored-procedures)  
- 🔔 [Triggers](#-triggers)  
- 🧪 [Sample Data](#-sample-data)  
- 🚀 [How to Run](#-how-to-run)  
- 📊 [Reports & Analytics](#-reports--analytics)  
- 🛡 [Future Enhancements](#-future-enhancements)  
- 🖼 [Screenshots](#-screenshots)  
- 🛠 [Tech Stack](#-tech-stack)  
- 👨‍💻 [Author](#-author)  

## ✨ Features  

✅ **Customer Management** – Store & retrieve customer details  
✅ **Account Management** – Manage Savings/Current accounts with balance tracking  
✅ **Transaction Handling** – Deposit, Withdraw, and Transfer money securely  
✅ **Loan Tracking** – Track loans with amount, interest rate & status  
✅ **Branch Operations** – Manage multiple branches and employees  
✅ **Audit & Alerts** – Low balance alerts & withdrawal audit logs via triggers  
✅ **Analytics & Reporting** – Branch summaries, top customers, and monthly transaction reports  

## 🗂 **Database Schema**  

The database contains **6 main tables**:  

- 🏢 **Branch** → Branch details  
- 👨‍💼 **Employee** → Employees working at branches  
- 🙍‍♂️ **Customer** → Customer personal information  
- 💳 **Account** → Linked to Customer & Branch  
- 📜 **TransactionHistory** → Logs deposits, withdrawals & transfers  
- 🏦 **Loan** → Tracks customer loans  

### 🔗 **Relationships**  

- A **Branch** has many **Employees**  
- A **Branch** has many **Accounts & Loans**  
- A **Customer** can have multiple **Accounts & Loans**  
- An **Account** can have multiple **TransactionHistory records**  

📸 **ER Diagram**  

<img width="1114" height="489" alt="ER Diagram" src="https://github.com/user-attachments/assets/d6fe944e-e6ac-4191-ada8-c4968f2c8b42" />  

---

## ⚙️ **Stored Procedures**  

- 🔹 **CreateCustomer** → Add a new customer  
- 🔹 **OpenAccount** → Open a new account with an initial deposit  
- 🔹 **DepositMoney** → Deposit money into an account  
- 🔹 **WithdrawMoney** → Withdraw money with balance check  
- 🔹 **TransferAmount** → Transfer funds between accounts (transaction safe)  
- 🔹 **ViewTransactionHistory** → View all transactions for an account  
- 🔹 **Reporting** → `GetBranchSummary`, `GetLoanStatusReport`  

---

## 🔔 **Triggers**  

- ⚠ **Low Balance Alert Trigger** → Alerts when balance < ₹1000  
- 📝 **Withdrawal Audit Trigger** → Logs all withdrawals into a `WithdrawalAudit` table  

---

## 🧪 **Sample Data**  

✔ **100+ sample customers created**  
✔ **100+ accounts opened**  
✔ **1000+ random deposits/withdrawals simulated**  
✔ **200+ random transfers generated**  

---

## 🚀 **How to Run**  

1️⃣ **Clone the repository**  

```bash
git clone https://github.com/Utkarshxtripathi/Banking_System.git
2️⃣ **Open SQL Server Management Studio (SSMS)**  

3️⃣ **Run the scripts in order:**  

- `banking_schema.sql` → Creates all tables  
- `banking_procedures.sql` → Creates stored procedures & triggers  
- `banking_sample_data.sql` → Inserts sample data & simulates transactions  
- `banking_reports.sql` → Creates views & reporting procedures  

4️⃣ **Test the database**  

```sql
EXEC CreateCustomer 'John Doe', 'Mumbai', '9876543210', 'john.doe@email.com';
EXEC OpenAccount 1, 1, 'Savings', 10000;
EXEC DepositMoney 1, 2000;
EXEC ViewTransactionHistory 1;
EXEC GetBranchSummary;
## 📊 **Reports & Analytics**  

📌 **Top Customers View**  
```sql
SELECT * FROM TopCustomers;
📌 Monthly Transaction Summary View

sql
Copy
Edit
SELECT * FROM MonthlyTransactionSummary;
📌 Branch Summary Report

sql
Copy
Edit
EXEC GetBranchSummary;
📌 Loan Status Report

sql
Copy
Edit
EXEC GetLoanStatusReport;
📸 Sample Report Screenshots
✅ Get Loan Status
<img width="270" height="183" alt="Loan Status" src="https://github.com/user-attachments/assets/a9d5911b-4322-42b4-b735-be6e3c73af96" />
<br>

✅ Get Branch Summary
<img width="460" height="201" alt="Branch Summary" src="https://github.com/user-attachments/assets/db04d18e-600b-4431-956f-100861970b35" />
<br>

✅ Monthly Transaction Summary
<img width="445" height="198" alt="Monthly Summary" src="https://github.com/user-attachments/assets/5465fbc3-a343-4cbe-b0fb-f830db0454d7" />
<br>

✅ Top Customers
<img width="284" height="190" alt="Top Customers" src="https://github.com/user-attachments/assets/ae0cac69-c9d1-4f49-b32a-a263ed9bf406" />
<br>

<img width="636" height="302" alt="Screenshot 5" src="https://github.com/user-attachments/assets/08b27bea-bbc9-45ec-a3b4-d5e36a93e357" /> <br> <img width="736" height="594" alt="Screenshot 6" src="https://github.com/user-attachments/assets/543bd3d5-3305-4791-b4f4-e7146de11f49" />
🛡 Future Enhancements
🚀 Role-Based Access Control (Admin, Teller, Viewer)
🚀 Automatic Interest Calculations for savings accounts
🚀 Loan EMI calculations & due date reminders
🚀 Credit/Debit Card module
🚀 Integration with Web/Mobile Apps (React/MERN)
🚀 SMS/Email notifications for transactions
🚀 AI-based fraud detection & predictive analytics

🛠 Tech Stack
Database: SQL Server

Procedures/Triggers: T-SQL

Optional Frontend: MERN stack for future UI integration

