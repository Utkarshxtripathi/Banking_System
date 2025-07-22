--- Banking System ---
--BY Utkarsh Tripathi	


-- STEP 1: CREATE DATABASE

CREATE DATABASE BankDB;
GO
USE BankDB;
GO

-- STEP 2: CORE TABLES

-- 2.1 Branch Table
CREATE TABLE Branch (
    BranchID INT PRIMARY KEY IDENTITY(1,1),
    BranchName VARCHAR(100) NOT NULL,
    Location VARCHAR(255),
    ManagerName VARCHAR(100)
);

-- 2.2 Employee Table
CREATE TABLE Employee (
    EmployeeID INT PRIMARY KEY IDENTITY(1,1),
    BranchID INT FOREIGN KEY REFERENCES Branch(BranchID),
    Name VARCHAR(100),
    Role VARCHAR(50),  
    Phone VARCHAR(15),
    Email VARCHAR(100)
);

-- 2.3 Customer Table
CREATE TABLE Customer (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    Name VARCHAR(100) NOT NULL,
    Address VARCHAR(255),
    Phone VARCHAR(15),
    Email VARCHAR(100) UNIQUE
);

-- 2.4 Account Table
CREATE TABLE Account (
    AccountID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT FOREIGN KEY REFERENCES Customer(CustomerID),
    BranchID INT FOREIGN KEY REFERENCES Branch(BranchID),
    AccountType VARCHAR(20) CHECK (AccountType IN ('Savings', 'Current')),
    Balance DECIMAL(15, 2) CHECK (Balance >= 0),
    OpenDate DATE DEFAULT GETDATE()
);

-- 2.5 Transaction History Table
CREATE TABLE TransactionHistory (
    TransactionID INT PRIMARY KEY IDENTITY(1,1),
    AccountID INT FOREIGN KEY REFERENCES Account(AccountID),
    Amount DECIMAL(15, 2),
    TransactionType VARCHAR(10), -- Deposit/Withdraw/Transfer
    TransactionDate DATETIME DEFAULT GETDATE(),
    Remarks VARCHAR(255)
);

-- 2.6 Loan Table
CREATE TABLE Loan (
    LoanID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT FOREIGN KEY REFERENCES Customer(CustomerID),
    BranchID INT FOREIGN KEY REFERENCES Branch(BranchID),
    LoanAmount DECIMAL(15,2),
    InterestRate DECIMAL(5,2),
    Status VARCHAR(20) CHECK (Status IN ('Approved','Pending','Closed')),
    IssueDate DATE DEFAULT GETDATE()
);

-- STEP 3: CORE STORED PROCEDURES

-- 3.1 Create Customer
CREATE PROCEDURE CreateCustomer
    @Name VARCHAR(100),
    @Address VARCHAR(255),
    @Phone VARCHAR(15),
    @Email VARCHAR(100)
AS
BEGIN
    INSERT INTO Customer (Name, Address, Phone, Email)
    VALUES (@Name, @Address, @Phone, @Email);
END;
GO

-- 3.2 Open Account
CREATE PROCEDURE OpenAccount
    @CustomerID INT,
    @BranchID INT,
    @AccountType VARCHAR(20),
    @InitialDeposit DECIMAL(15,2)
AS
BEGIN
    INSERT INTO Account (CustomerID, BranchID, AccountType, Balance)
    VALUES (@CustomerID, @BranchID, @AccountType, @InitialDeposit);

    DECLARE @NewAccountID INT = SCOPE_IDENTITY();

    INSERT INTO TransactionHistory (AccountID, Amount, TransactionType, Remarks)
    VALUES (@NewAccountID, @InitialDeposit, 'Deposit', 'Initial Deposit');
END;
GO

-- 3.3 Deposit Money
CREATE PROCEDURE DepositMoney
    @AccountID INT,
    @Amount DECIMAL(15,2)
AS
BEGIN
    UPDATE Account
    SET Balance = Balance + @Amount
    WHERE AccountID = @AccountID;

    INSERT INTO TransactionHistory (AccountID, Amount, TransactionType, Remarks)
    VALUES (@AccountID, @Amount, 'Deposit', 'Money Deposited');
END;
GO

-- 3.4 Withdraw Money
CREATE PROCEDURE WithdrawMoney
    @AccountID INT,
    @Amount DECIMAL(15,2)
AS
BEGIN
    DECLARE @CurrentBalance DECIMAL(15,2);
    SELECT @CurrentBalance = Balance FROM Account WHERE AccountID = @AccountID;

    IF @CurrentBalance >= @Amount
    BEGIN
        UPDATE Account
        SET Balance = Balance - @Amount
        WHERE AccountID = @AccountID;

        INSERT INTO TransactionHistory (AccountID, Amount, TransactionType, Remarks)
        VALUES (@AccountID, @Amount, 'Withdraw', 'Money Withdrawn');
    END
    ELSE
    BEGIN
        RAISERROR('Insufficient balance.', 16, 1);
    END
END;
GO

-- 3.5 Transfer Money
CREATE PROCEDURE TransferAmount
    @FromAccountID INT,
    @ToAccountID INT,
    @Amount DECIMAL(15,2)
AS
BEGIN
    DECLARE @FromBalance DECIMAL(15,2);
    SELECT @FromBalance = Balance FROM Account WHERE AccountID = @FromAccountID;

    IF @FromBalance >= @Amount
    BEGIN
        BEGIN TRANSACTION;

        -- Deduct from sender
        UPDATE Account SET Balance = Balance - @Amount WHERE AccountID = @FromAccountID;
        INSERT INTO TransactionHistory (AccountID, Amount, TransactionType, Remarks)
        VALUES (@FromAccountID, @Amount, 'Transfer', CONCAT('Transferred to AccountID ', @ToAccountID));

        -- Credit to receiver
        UPDATE Account SET Balance = Balance + @Amount WHERE AccountID = @ToAccountID;
        INSERT INTO TransactionHistory (AccountID, Amount, TransactionType, Remarks)
        VALUES (@ToAccountID, @Amount, 'Deposit', CONCAT('Received from AccountID ', @FromAccountID));

        COMMIT;
    END
    ELSE
    BEGIN
        RAISERROR('Insufficient balance for transfer.', 16, 1);
        ROLLBACK;
    END
END;
GO

-- 3.6 View Transaction History
CREATE PROCEDURE ViewTransactionHistory
    @AccountID INT
AS
BEGIN
    SELECT * FROM TransactionHistory
    WHERE AccountID = @AccountID
    ORDER BY TransactionDate DESC;
END;
GO

-- STEP 4: TRIGGERS FOR INTELLIGENCE

-- Trigger: Low Balance Alert
CREATE TRIGGER trg_LowBalance
ON Account
AFTER UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE Balance < 1000)
    BEGIN
        PRINT 'LOW BALANCE ALERT: Some accounts have less than ₹1000!';
    END
END;
GO

-- Trigger: Audit Withdrawals
CREATE TABLE WithdrawalAudit (
    AuditID INT PRIMARY KEY IDENTITY(1,1),
    AccountID INT,
    WithdrawAmount DECIMAL(15,2),
    AuditDate DATETIME DEFAULT GETDATE()
);

CREATE TRIGGER trg_AuditWithdraw
ON TransactionHistory
AFTER INSERT
AS
BEGIN
    INSERT INTO WithdrawalAudit(AccountID, WithdrawAmount)
    SELECT AccountID, Amount FROM inserted WHERE TransactionType='Withdraw';
END;
GO

-- STEP 5: VIEWS FOR REPORTING

-- View: Monthly Transaction Summary
CREATE VIEW MonthlyTransactionSummary AS
SELECT 
    AccountID,
    FORMAT(TransactionDate, 'yyyy-MM') AS Month,
    COUNT(*) AS TotalTransactions,
    SUM(CASE WHEN TransactionType='Deposit' THEN Amount ELSE 0 END) AS TotalDeposited,
    SUM(CASE WHEN TransactionType='Withdraw' THEN Amount ELSE 0 END) AS TotalWithdrawn
FROM TransactionHistory
GROUP BY AccountID, FORMAT(TransactionDate, 'yyyy-MM');
GO

-- View: Top Customers (By Balance)
CREATE VIEW TopCustomers AS
SELECT TOP 5 
    C.CustomerID, 
    C.Name, 
    SUM(A.Balance) AS TotalBalance
FROM Customer C
JOIN Account A ON C.CustomerID = A.CustomerID
GROUP BY C.CustomerID, C.Name
ORDER BY TotalBalance DESC;
GO

-- STEP 6: REPORTING PROCEDURES

-- Get Branch Summary
CREATE PROCEDURE GetBranchSummary
AS
BEGIN
    SELECT 
        B.BranchID, B.BranchName,
        COUNT(DISTINCT A.AccountID) AS TotalAccounts,
        SUM(A.Balance) AS TotalDeposits,
        COUNT(DISTINCT L.LoanID) AS TotalLoansIssued
    FROM Branch B
    LEFT JOIN Account A ON B.BranchID = A.BranchID
    LEFT JOIN Loan L ON B.BranchID = L.BranchID
    GROUP BY B.BranchID, B.BranchName;
END;
GO

-- Get Loan Status Summary
CREATE PROCEDURE GetLoanStatusReport
AS
BEGIN
    SELECT Status, COUNT(*) AS TotalLoans, SUM(LoanAmount) AS TotalAmount
    FROM Loan
    GROUP BY Status;
END;
GO
-- STEP 7: SAMPLE DATA

-- Inserting Sample Branches
INSERT INTO Branch (BranchName, Location, ManagerName)
VALUES ('Lucknow Main', 'Lucknow', 'Mr. Sharma'),
       ('Delhi Central', 'Delhi', 'Ms. Kapoor');

-- Inserting Sample Customers
EXEC CreateCustomer 'Utkarsh Tripathi', 'Lucknow', '9999999999', 'utkarsh@email.com';
EXEC CreateCustomer 'Arundhati Singh', 'Delhi', '8888888888', 'arundhati@email.com';

-- Open Sample Accounts
EXEC OpenAccount 1, 1, 'Savings', 10000;  -- Utkarsh in Lucknow branch
EXEC OpenAccount 2, 2, 'Current', 15000;  -- Arundhati in Delhi branch

-- Sample Transactions
EXEC DepositMoney 1, 2000;
EXEC WithdrawMoney 1, 500;
EXEC TransferAmount 1, 2, 3000;

-- Sample Loan
INSERT INTO Loan (CustomerID, BranchID, LoanAmount, InterestRate, Status)
VALUES (1, 1, 50000, 7.5, 'Approved'),
       (2, 2, 75000, 8.0, 'Pending');


-- STEP 8: TEST REPORTING

-- See Transaction History
EXEC ViewTransactionHistory 1;

-- See Top Customers
SELECT * FROM TopCustomers;

-- See Monthly Summary
SELECT * FROM MonthlyTransactionSummary;

-- See Branch Summary
EXEC GetBranchSummary;

-- See Loan Status Report
EXEC GetLoanStatusReport;

-- See Low Balance Trigger in action
UPDATE Account SET Balance = 500 WHERE AccountID = 1;
GO


SELECT * FROM TopCustomers;
SELECT * FROM MonthlyTransactionSummary;
EXEC GetBranchSummary;
EXEC GetLoanStatusReport;