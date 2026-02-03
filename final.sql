DROP DATABASE IF EXISTS FinalTest;
CREATE DATABASE FinalTest;
USE FinalTest;
SET SQL_SAFE_UPDATES = 0;


-- Bảng Customers (Khách hàng)
CREATE TABLE Customers (
    customer_id VARCHAR(10) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(15) NOT NULL,
    email VARCHAR(100) NOT NULL,
    join_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    CONSTRAINT pk_customers PRIMARY KEY (customer_id),
    CONSTRAINT uq_phone UNIQUE (phone_number)
);


-- Bảng Insurance_Packages (Gói bảo hiểm)
CREATE TABLE Insurance_Packages (
    package_id VARCHAR(10) NOT NULL,
    package_name VARCHAR(100) NOT NULL,
    max_limit DECIMAL(15, 2) NOT NULL,
    base_premium DECIMAL(15, 2) NOT NULL CHECK (base_premium > 0),
    CONSTRAINT pk_packages PRIMARY KEY (package_id),
    CONSTRAINT chk_max_limit CHECK (max_limit > 0)
);


-- Bảng Policies (Hợp đồng bảo hiểm)
CREATE TABLE Policies (
    policy_id VARCHAR(10) NOT NULL,
    customer_id VARCHAR(10) NOT NULL,
    package_id VARCHAR(10) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status ENUM('Active', 'Expired', 'Cancelled') NOT NULL DEFAULT 'Active',
    CONSTRAINT pk_policies PRIMARY KEY (policy_id),
    CONSTRAINT fk_policies_customers FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    CONSTRAINT fk_policies_packages FOREIGN KEY (package_id) REFERENCES Insurance_Packages(package_id)
);


-- Bảng Claims (Yêu cầu bồi thường)
CREATE TABLE Claims (
    claim_id VARCHAR(10) NOT NULL,
    policy_id VARCHAR(10) NOT NULL,
    claim_date DATE NOT NULL,
    claim_amount DECIMAL(15, 2) NOT NULL,
    status ENUM('Pending', 'Approved', 'Rejected') NOT NULL DEFAULT 'Pending',
    CONSTRAINT pk_claims PRIMARY KEY (claim_id),
    CONSTRAINT fk_claims_policies FOREIGN KEY (policy_id) REFERENCES Policies(policy_id),
    CONSTRAINT chk_claim_amount CHECK (claim_amount > 0)
);


-- Bảng Claim_Processing_Log (Nhật ký xử lý)
CREATE TABLE Claim_Processing_Log (
    log_id VARCHAR(50) NOT NULL,
    claim_id VARCHAR(10),
    action_detail TEXT NOT NULL,
    recorded_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    processor VARCHAR(50) NOT NULL,
    CONSTRAINT pk_logs PRIMARY KEY (log_id),
    CONSTRAINT fk_logs_claims FOREIGN KEY (claim_id) REFERENCES Claims(claim_id)
);


-- Chèn dữ liệu Customers
INSERT INTO Customers (customer_id, full_name, phone_number, email, join_date) VALUES
	('C001', 'Nguyen Hoang Long', '0901112223', 'long.nh@gmail.com', '2024-01-15'),
	('C002', 'Tran Thi Kim Anh', '0988877766', 'anh.tk@yahoo.com', '2024-03-10'),
	('C003', 'Le Hoang Nam', '0903334445', 'nam.lh@outlook.com', '2025-05-20'),
	('C004', 'Pham Minh Duc', '0355556667', 'duc.pm@gmail.com', '2025-08-12'),
	('C005', 'Hoang Thu Thao', '0779998881', 'thao.ht@gmail.com', '2026-01-01');


-- Chèn dữ liệu Insurance_Packages
INSERT INTO Insurance_Packages (package_id, package_name, max_limit, base_premium) VALUES
	('PKG01', 'Bảo hiểm Sức khỏe Gold', 500000000, 5000000),
	('PKG02', 'Bảo hiểm Ô tô Liberty', 1000000000, 15000000),
	('PKG03', 'Bảo hiểm Nhân thọ An Bình', 2000000000, 25000000),
	('PKG04', 'Bảo hiểm Du lịch Quốc tế', 100000000, 1000000),
	('PKG05', 'Bảo hiểm Tai nạn 24/7', 200000000, 2500000);


-- Chèn dữ liệu Policies
INSERT INTO Policies (policy_id, customer_id, package_id, start_date, end_date, status) VALUES
	('POL101', 'C001', 'PKG01', '2024-01-15', '2025-01-15', 'Expired'),
	('POL102', 'C002', 'PKG02', '2024-03-10', '2026-03-10', 'Active'),
	('POL103', 'C003', 'PKG03', '2025-05-20', '2035-05-20', 'Active'),
	('POL104', 'C004', 'PKG04', '2025-08-12', '2025-09-12', 'Expired'),
	('POL105', 'C005', 'PKG01', '2026-01-01', '2027-01-01', 'Active');


-- Chèn dữ liệu Claims
INSERT INTO Claims (claim_id, policy_id, claim_date, claim_amount, status) VALUES
	('CLM901', 'POL102', '2024-06-15', 12000000, 'Approved'),
	('CLM902', 'POL103', '2025-10-20', 50000000, 'Pending'),
	('CLM903', 'POL101', '2024-11-05', 5500000, 'Approved'),
	('CLM904', 'POL105', '2026-01-15', 2000000, 'Rejected'),
	('CLM905', 'POL102', '2025-02-10', 120000000, 'Approved');


-- Chèn dữ liệu Log (Nhớ dùng UUID cho Log_ID vì DDL trên mình để VARCHAR(50))
INSERT INTO Claim_Processing_Log (log_id, claim_id, action_detail, recorded_at, processor) VALUES
	('L001', 'CLM901', 'Đã nhận hồ sơ hiện trường', '2024-06-15 09:00:00', 'Admin_01'),
	('L002', 'CLM901', 'Chấp nhận bồi thường xe tai nạn', '2024-06-20 14:30:00', 'Admin_01'),
	('L003', 'CLM902', 'Đang thẩm định hồ sơ bệnh án', '2025-10-21 10:00:00', 'Admin_02'),
	('L004', 'CLM904', 'Từ chối do lỗi cố ý của khách hàng', '2026-01-16 16:00:00', 'Admin_03'),
	('L005', 'CLM905', 'Đã thanh toán qua chuyển khoản', '2025-02-15 08:30:00', 'Accountant_01');


-- Tăng phí bảo hiểm cơ bản thêm 15% cho các gói bảo hiểm có hạn mức chi trả trên 500.000.000 VNĐ.
UPDATE Insurance_Packages SET base_premium = base_premium * 1.15 WHERE max_limit > 500000000;

-- Xóa các nhật ký xử lý bồi thường (Claim_Processing_Log) được ghi nhận trước ngày 20/6/2025.
DELETE FROM Claim_Processing_Log WHERE recorded_at < '2025-06-20';

-- Liệt kê thông tin các hợp đồng có trạng thái 'Active' và có ngày kết thúc trong năm 2026.
SELECT * FROM Policies WHERE status = 'Active' AND YEAR(end_date) = 2026;

-- Lấy thông tin khách hàng (Họ tên, Email) có tên chứa chữ 'Hoàng' và tham gia bảo hiểm từ năm 2025 trở lại đây.
SELECT full_name, email FROM Customers WHERE full_name LIKE '%Hoàng%' AND YEAR(join_date) >= 2025;

-- Hiển thị top 3 yêu cầu bồi thường (Claims) có số tiền được yêu cầu cao nhất, bỏ qua yêu cầu cao nhất (lấy từ vị trí số 2 đến số 4).
SELECT * FROM Claims ORDER BY claim_amount DESC LIMIT 3 OFFSET 1;

-- Sử dụng JOIN để hiển thị: Tên khách hàng, Tên gói bảo hiểm, Ngày bắt đầu hợp đồng và Số tiền bồi thường (nếu có).
SELECT c.full_name, ip.package_name, p.start_date, cl.claim_amount
FROM Customers c
JOIN Policies p ON c.customer_id = p.customer_id
JOIN Insurance_Packages ip ON p.package_id = ip.package_id
LEFT JOIN Claims cl ON p.policy_id = cl.policy_id;

-- Thống kê tổng số tiền bồi thường đã chi trả ('Approved') cho từng khách hàng. Chỉ hiện những người có tổng chi trả > 50.000.000 VNĐ.
SELECT c.customer_id, c.full_name, SUM(cl.claim_amount) AS Total_Approved
FROM Customers c
JOIN Policies p ON c.customer_id = p.customer_id
JOIN Claims cl ON p.policy_id = cl.policy_id
WHERE cl.status = 'Approved'
GROUP BY c.customer_id, c.full_name
HAVING SUM(cl.claim_amount) > 50000000;

-- Tìm gói bảo hiểm có số lượng khách hàng đăng ký nhiều nhất.
SELECT ip.package_id, ip.package_name, COUNT(p.customer_id) AS Num_Customers
FROM Insurance_Packages ip
JOIN Policies p ON ip.package_id = p.package_id
GROUP BY ip.package_id, ip.package_name
ORDER BY Num_Customers DESC LIMIT 1;

-- Tạo Composite Index tên idx_policy_status_date trên bảng Policies cho hai cột: status và start_date.
CREATE INDEX idx_policy_status_date ON Policies(status, start_date);

-- Tạo một View tên vw_customer_summary hiển thị: Tên khách hàng, Số lượng hợp đồng đang sở hữu, và Tổng phí bảo hiểm định kỳ họ phải trả.
CREATE VIEW vw_customer_summary AS
SELECT c.full_name, COUNT(p.policy_id) AS Active_Contracts, COALESCE(SUM(ip.base_premium), 0) AS Total_Premium
FROM Customers c
LEFT JOIN Policies p ON c.customer_id = p.customer_id AND p.status = 'Active'
LEFT JOIN Insurance_Packages ip ON p.package_id = ip.package_id
GROUP BY c.customer_id, c.full_name;

-- Viết Trigger trg_after_claim_approved. Khi một yêu cầu bồi thường chuyển trạng thái sang 'Approved', tự động thêm một dòng vào Claim_Processing_Log với nội dung 'Payment processed to customer'.
DELIMITER //
CREATE TRIGGER trg_after_claim_approved
AFTER UPDATE ON Claims
FOR EACH ROW
BEGIN
    IF NEW.status = 'Approved' AND OLD.status != 'Approved' THEN
        INSERT INTO Claim_Processing_Log (log_id, claim_id, action_detail, recorded_at, processor)
        VALUES (UUID(), NEW.claim_id, 'Payment processed to customer', NOW(), 'System_Trigger');
    END IF;
END //
DELIMITER ;

-- Viết Trigger ngăn chặn việc xóa hợp đồng nếu trạng thái của hợp đồng đó đang là 'Active'.
DELIMITER //
CREATE TRIGGER trg_prevent_policy_delete
BEFORE DELETE ON Policies
FOR EACH ROW
BEGIN
    IF OLD.status = 'Active' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot delete Active policy';
    END IF;
END //
DELIMITER ;

/* 
	Viết Procedure sp_check_claim_limit nhận vào Mã yêu cầu bồi thường. Trả về tham số OUT message:
		- 'Exceeded' nếu Số tiền yêu cầu > Hạn mức chi trả của gói bảo hiểm tương ứng.
		- 'Valid' nếu Số tiền yêu cầu <= Hạn mức chi trả.
*/
DELIMITER //
CREATE PROCEDURE sp_check_claim_limit(IN p_claim_id VARCHAR(10), OUT p_message VARCHAR(50))
BEGIN
    DECLARE v_claim_amount DECIMAL(15,2);
    DECLARE v_max_limit DECIMAL(15,2);

    SELECT cl.claim_amount, ip.max_limit INTO v_claim_amount, v_max_limit
    FROM Claims cl
    JOIN Policies p ON cl.policy_id = p.policy_id
    JOIN Insurance_Packages ip ON p.package_id = ip.package_id
    WHERE cl.claim_id = p_claim_id;

    IF v_claim_amount > v_max_limit THEN SET p_message = 'Exceeded';
    ELSE SET p_message = 'Valid';
    END IF;
END //
DELIMITER ;

/* 
	Viết Procedure sp_cancel_policy để hủy một hợp đồng:
        - Bắt đầu giao dịch (Transaction).
		- Cập nhật trạng thái hợp đồng thành 'Cancelled'.
		- Ghi log vào Claim_Processing_Log lý do 'Customer requested cancellation'.
		- COMMIT nếu thành công, ROLLBACK nếu có lỗi xảy ra.
*/
DELIMITER //
CREATE PROCEDURE sp_cancel_policy(IN p_policy_id VARCHAR(10))
BEGIN
    DECLARE exit handler for sqlexception
    BEGIN
        ROLLBACK;
        SELECT 'Transaction rolled back' AS Result;
    END;

    START TRANSACTION;
        UPDATE Policies SET status = 'Cancelled' WHERE policy_id = p_policy_id;
        INSERT INTO Claim_Processing_Log (log_id, claim_id, action_detail, recorded_at, processor)
        VALUES (UUID(), NULL, 'Customer requested cancellation', NOW(), 'System_Admin');
    COMMIT;
    SELECT 'Policy cancelled successfully' AS Result;
END //
DELIMITER ;