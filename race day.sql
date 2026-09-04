-- 1. User  no FKs  created first
-- =========================================================
CREATE TABLE dbo.[User] (
    UserID          INT IDENTITY(1,1) PRIMARY KEY,
    FullName        NVARCHAR(100)   NOT NULL,
    Email           NVARCHAR(150)   NOT NULL UNIQUE,
    PasswordHash    NVARCHAR(255)   NOT NULL,
    Role            NVARCHAR(20)    NOT NULL
    CHECK (Role IN ('Organiser', 'Participant')),
    PhoneNumber     NVARCHAR(20)    NULL,
    CreatedAt       DATETIME        NOT NULL DEFAULT GETDATE()
);
GO

-- =========================================================
--  Event FK user
-- =========================================================
CREATE TABLE dbo.Event (
    EventID         INT IDENTITY(1,1) PRIMARY KEY,
    OrganiserID     INT             NOT NULL,
    EventName       NVARCHAR(150)   NOT NULL,
    EventDate       DATE            NOT NULL,
    Location        NVARCHAR(150)   NOT NULL,
    Description     NVARCHAR(MAX)   NULL,
    Status          NVARCHAR(20)    NOT NULL DEFAULT 'Planned'
   CHECK (Status IN ('Planned','Open','Closed','Cancelled','Completed')),
    CONSTRAINT FK_Event_Organiser FOREIGN KEY (OrganiserID)
        REFERENCES dbo.[User](UserID)
);
GO

-- =========================================================
-- 3. Category  FK Event
-- =========================================================
CREATE TABLE dbo.Category (
    CategoryID      INT IDENTITY(1,1) PRIMARY KEY,
    EventID         INT             NOT NULL,
    CategoryName    NVARCHAR(100)   NOT NULL,
    DistanceKm      DECIMAL(5,2)    NOT NULL,
    EntryFee        DECIMAL(8,2)    NOT NULL DEFAULT 0,
    MaxParticipants INT             NOT NULL,
    CONSTRAINT FK_Category_Event FOREIGN KEY (EventID)
        REFERENCES dbo.Event(EventID)
);
GO

-- =========================================================
-- 4. Route FK Event
-- =========================================================
CREATE TABLE dbo.Route (
    RouteID         INT IDENTITY(1,1) PRIMARY KEY,
    EventID         INT             NOT NULL,
    RouteName       NVARCHAR(100)   NOT NULL,
    RouteMapURL     NVARCHAR(255)   NULL,
    ElevationGainM  INT             NULL,
    CONSTRAINT FK_Route_Event FOREIGN KEY (EventID)
        REFERENCES dbo.Event(EventID)
);
GO

-- =========================================================
-- 5. EventEnrolment FK User,Event,Category
-- =========================================================
CREATE TABLE dbo.EventEnrolment (
    EnrolmentID     INT IDENTITY(1,1) PRIMARY KEY,
    UserID          INT             NOT NULL,
    EventID         INT             NOT NULL,
    CategoryID      INT             NOT NULL,
    EnrolmentDate   DATETIME        NOT NULL DEFAULT GETDATE(),
    PaymentStatus   NVARCHAR(20)    NOT NULL DEFAULT 'Pending'
        CHECK (PaymentStatus IN ('Pending', 'Paid', 'Refunded')),
    BibNumber     NVARCHAR(10)    NULL UNIQUE,
    CONSTRAINT FK_Enrolment_User FOREIGN KEY (UserID)
        REFERENCES dbo.[User](UserID),
    CONSTRAINT FK_Enrolment_Event FOREIGN KEY (EventID)
        REFERENCES dbo.Event(EventID),
    CONSTRAINT FK_Enrolment_Category FOREIGN KEY (CategoryID)
        REFERENCES dbo.Category(CategoryID)
);
GO

-- =========================================================
-- 6.Result  FK EventEnrolment
-- =========================================================
CREATE TABLE dbo.Result (
    ResultID        INT IDENTITY(1,1) PRIMARY KEY,
    EnrolmentID     INT             NOT NULL,
    FinishTime      TIME            NULL,
    Position        INT             NULL,
    Status          NVARCHAR(20)    NOT NULL DEFAULT 'Finished'
     CHECK (Status IN ('Finished', 'DNF', 'DQ')),
    CONSTRAINT FK_Result_Enrolment FOREIGN KEY (EnrolmentID)
     REFERENCES dbo.EventEnrolment(EnrolmentID)
);
GO


-- =========================================================
-- SEED DATA
-- =========================================================

-- 2 Organisers + 2 Participants
INSERT INTO dbo.[User] (FullName,Email,PasswordHash,Role,PhoneNumber)
VALUES
('Thabo Nkosi',   'thabo.nkosi@raceday.co.za',  'hashed_pw_1', 'Organiser',  '0821234567'),
('Lindiwe Dube',  'lindiwe.dube@raceday.co.za', 'hashed_pw_2', 'Organiser',  '0837654321'),
('Sipho Mokoena', 'sipho.mokoena@example.com', 'hashed_pw_3', 'Participant','0731112222'),
('Anza Khumalo',  'anza.khumalo@example.com',  'hashed_pw_4', 'Participant','0793334444');

-- 3 Events organised by the two organisers above
INSERT INTO dbo.Event (OrganiserID,EventName,EventDate,Location,Description,Status)
VALUES
(1, 'Johannesburg City Trail Run', '2026-10-10', 'Johannesburg, Gauteng', 'Annual trail run through the city parks.', 'Open'),
(1, 'Soweto Half Marathon',   '2026-11-02', 'Soweto, Gauteng',    'Half marathon supporting local charities.', 'Open'),
(2, 'Pretoria Fun Run',    '2026-09-20', 'Pretoria, Gauteng',   'Family-friendly fun run and walk.', 'Planned');

-- Categories for each event
INSERT INTO dbo.Category (EventID, CategoryName, DistanceKm, EntryFee, MaxParticipants)
VALUES
(1, '5km Fun Run',   5.00,  100.00, 200),
(1, '10km Trail',    10.00, 150.00, 150),
(2, '21.1km Half',   21.10, 250.00, 300),
(2, '10km',          10.00, 150.00, 200),
(3, '5km Family Walk', 5.00, 50.00, 250);

-- Routes for each event
INSERT INTO dbo.Route (EventID, RouteName, RouteMapURL, ElevationGainM)
VALUES
(1, 'City Park Loop',     'https://maps.raceday.co.za/route/1', 120),
(2, 'Soweto Half Route',  'https://maps.raceday.co.za/route/2', 250),
(3, 'Pretoria Park Route','https://maps.raceday.co.za/route/3', 40);

-- Sample enrolments participants entering events
INSERT INTO dbo.EventEnrolment (UserID, EventID, CategoryID, PaymentStatus, BibNumber)
VALUES
(3, 1, 2, 'Paid',    'BIB1001'),
(4, 1, 1, 'Paid',    'BIB1002'),
(3, 2, 3, 'Pending', 'BIB2001'),
(4, 3, 5, 'Paid',    'BIB3001');

-- Sample results for finished enrolments
INSERT INTO dbo.Result (EnrolmentID, FinishTime, Position, Status)
VALUES
(1, '00:52:30', 3, 'Finished'),
(2, '00:28:10', 1, 'Finished');