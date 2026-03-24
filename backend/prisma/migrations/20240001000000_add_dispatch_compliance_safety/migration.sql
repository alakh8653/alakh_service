-- AlakhService: Supplementary migration adding Dispatch, LocationHistory,
-- ComplianceRequirement, and SafetyReport models that were absent from the
-- initial BE-1 schema.

-- ──────────────────────────────────────────────────────────────────────────────
-- Enums
-- ──────────────────────────────────────────────────────────────────────────────

CREATE TYPE "DispatchStatus" AS ENUM (
  'PENDING',
  'ACCEPTED',
  'REJECTED',
  'EN_ROUTE',
  'ARRIVED',
  'IN_PROGRESS',
  'COMPLETED',
  'CANCELLED'
);

CREATE TYPE "WalletTxnType" AS ENUM (
  'CREDIT',
  'DEBIT',
  'REFUND',
  'REFERRAL_REWARD',
  'CASHBACK'
);

CREATE TYPE "ReportStatus" AS ENUM (
  'PENDING',
  'UNDER_REVIEW',
  'RESOLVED',
  'DISMISSED'
);

-- ──────────────────────────────────────────────────────────────────────────────
-- Dispatch
-- ──────────────────────────────────────────────────────────────────────────────

CREATE TABLE "dispatches" (
  "id"                  TEXT         NOT NULL DEFAULT gen_random_uuid()::text,
  "bookingId"           TEXT         NOT NULL,
  "staffId"             TEXT,
  "customerId"          TEXT         NOT NULL,
  "shopId"              TEXT         NOT NULL,
  "status"              "DispatchStatus" NOT NULL DEFAULT 'PENDING',
  "assignedAt"          TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "acceptedAt"          TIMESTAMP(3),
  "startedAt"           TIMESTAMP(3),
  "arrivedAt"           TIMESTAMP(3),
  "completedAt"         TIMESTAMP(3),
  "cancelledAt"         TIMESTAMP(3),
  "staffLatitude"       DOUBLE PRECISION,
  "staffLongitude"      DOUBLE PRECISION,
  "destLatitude"        DOUBLE PRECISION NOT NULL,
  "destLongitude"       DOUBLE PRECISION NOT NULL,
  "estimatedArrival"    TIMESTAMP(3),
  "actualDuration"      INTEGER,
  "rejectionReason"     TEXT,
  "cancellationReason"  TEXT,
  "createdAt"           TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt"           TIMESTAMP(3) NOT NULL,

  CONSTRAINT "dispatches_pkey" PRIMARY KEY ("id")
);

CREATE INDEX "dispatches_bookingId_idx"  ON "dispatches"("bookingId");
CREATE INDEX "dispatches_staffId_idx"    ON "dispatches"("staffId");
CREATE INDEX "dispatches_customerId_idx" ON "dispatches"("customerId");
CREATE INDEX "dispatches_shopId_idx"     ON "dispatches"("shopId");
CREATE INDEX "dispatches_status_idx"     ON "dispatches"("status");

-- ──────────────────────────────────────────────────────────────────────────────
-- LocationHistory
-- ──────────────────────────────────────────────────────────────────────────────

CREATE TABLE "location_history" (
  "id"          TEXT             NOT NULL DEFAULT gen_random_uuid()::text,
  "dispatchId"  TEXT             NOT NULL,
  "latitude"    DOUBLE PRECISION NOT NULL,
  "longitude"   DOUBLE PRECISION NOT NULL,
  "heading"     DOUBLE PRECISION,
  "speed"       DOUBLE PRECISION,
  "accuracy"    DOUBLE PRECISION,
  "recordedAt"  TIMESTAMP(3)     NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT "location_history_pkey" PRIMARY KEY ("id")
);

CREATE INDEX "location_history_dispatchId_idx" ON "location_history"("dispatchId");
CREATE INDEX "location_history_recordedAt_idx" ON "location_history"("recordedAt");

ALTER TABLE "location_history"
  ADD CONSTRAINT "location_history_dispatchId_fkey"
  FOREIGN KEY ("dispatchId") REFERENCES "dispatches"("id")
  ON DELETE RESTRICT ON UPDATE CASCADE;

-- ──────────────────────────────────────────────────────────────────────────────
-- ComplianceRequirement
-- ──────────────────────────────────────────────────────────────────────────────

CREATE TABLE "compliance_requirements" (
  "id"                    TEXT     NOT NULL DEFAULT gen_random_uuid()::text,
  "type"                  TEXT     NOT NULL,
  "name"                  TEXT     NOT NULL,
  "description"           TEXT,
  "applicableCategories"  TEXT[]   NOT NULL DEFAULT '{}',
  "applicableCities"      TEXT[]   NOT NULL DEFAULT '{}',
  "isRequired"            BOOLEAN  NOT NULL DEFAULT true,
  "validityPeriodDays"    INTEGER,
  "isActive"              BOOLEAN  NOT NULL DEFAULT true,
  "createdAt"             TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt"             TIMESTAMP(3) NOT NULL,

  CONSTRAINT "compliance_requirements_pkey" PRIMARY KEY ("id")
);

CREATE INDEX "compliance_requirements_isActive_idx" ON "compliance_requirements"("isActive");

-- ──────────────────────────────────────────────────────────────────────────────
-- SafetyReport
-- ──────────────────────────────────────────────────────────────────────────────

CREATE TABLE "safety_reports" (
  "id"             TEXT          NOT NULL DEFAULT gen_random_uuid()::text,
  "reportedBy"     TEXT          NOT NULL,
  "reportedUserId" TEXT          NOT NULL,
  "type"           TEXT          NOT NULL,
  "description"    TEXT          NOT NULL,
  "status"         "ReportStatus" NOT NULL DEFAULT 'PENDING',
  "resolvedAt"     TIMESTAMP(3),
  "resolvedBy"     TEXT,
  "resolution"     TEXT,
  "createdAt"      TIMESTAMP(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT "safety_reports_pkey" PRIMARY KEY ("id")
);

CREATE INDEX "safety_reports_reportedUserId_idx" ON "safety_reports"("reportedUserId");
CREATE INDEX "safety_reports_status_idx"         ON "safety_reports"("status");
