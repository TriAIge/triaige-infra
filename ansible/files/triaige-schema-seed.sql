-- TriAIge 

CREATE DATABASE IF NOT EXISTS triaige;

USE triaige;

CREATE TABLE law_firms (
    id              CHAR(36)     NOT NULL,
    nome            VARCHAR(200) NOT NULL,
    cnpj            VARCHAR(20),
    email_contato   VARCHAR(200),
    telefone        VARCHAR(30),
    status          VARCHAR(30)  NOT NULL,
    created_at      DATETIME(6)  NOT NULL,
    updated_at      DATETIME(6)  NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_law_firms_cnpj (cnpj),
    INDEX idx_law_firms_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE law_firm_contacts (
    id                 CHAR(36)     NOT NULL,
    law_firm_id         CHAR(36)     NOT NULL,
    nome               VARCHAR(200) NOT NULL,
    email              VARCHAR(200),
    telefone           VARCHAR(30),
    canal_preferencial VARCHAR(20)  NOT NULL,
    ativo              TINYINT(1)   NOT NULL DEFAULT 1,
    created_at         DATETIME(6)  NOT NULL,
    updated_at         DATETIME(6)  NOT NULL,
    PRIMARY KEY (id),
    INDEX idx_law_firm_contacts_law_firm_id (law_firm_id),
    INDEX idx_law_firm_contacts_email (email),
    CONSTRAINT fk_law_firm_contacts_law_firm FOREIGN KEY (law_firm_id)
        REFERENCES law_firms(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE api_credentials (
    id              CHAR(36)     NOT NULL,
    law_firm_id      CHAR(36)     NOT NULL,
    name            VARCHAR(100) NOT NULL,
    token_hash      VARCHAR(255) NOT NULL,
    status          VARCHAR(30)  NOT NULL,
    last_used_at    DATETIME(6),
    expires_at      DATETIME(6),
    created_at      DATETIME(6)  NOT NULL,
    updated_at      DATETIME(6)  NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_api_credentials_token_hash (token_hash),
    INDEX idx_api_credentials_law_firm_id (law_firm_id),
    INDEX idx_api_credentials_status (status),
    CONSTRAINT fk_api_credentials_law_firm FOREIGN KEY (law_firm_id)
        REFERENCES law_firms(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- Suporte a idempotência (spec Fase 1, seção 8). Adicionada fora do desenho
-- inicial deste arquivo; TTL de 24h aplicado via expires_at (limpeza por job
-- futuro ou consulta filtrando expires_at > NOW(6); não há DROP automático).
CREATE TABLE idempotency_records (
    idempotency_key CHAR(36)     NOT NULL,
    endpoint        VARCHAR(150) NOT NULL,
    request_hash    VARCHAR(64)  NOT NULL,
    response_body   MEDIUMTEXT   NOT NULL,
    status_code     INT          NOT NULL,
    created_at      DATETIME(6)  NOT NULL,
    expires_at      DATETIME(6)  NOT NULL,
    PRIMARY KEY (idempotency_key, endpoint),
    INDEX idx_idempotency_records_expires_at (expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE protocol_sequences (
    year          INT    NOT NULL,
    last_sequence BIGINT NOT NULL DEFAULT 0,
    PRIMARY KEY (year)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE triage_sessions (
    id                CHAR(36)     NOT NULL,
    law_firm_id        CHAR(36)     NOT NULL,
    api_credential_id  CHAR(36),
    protocolo         VARCHAR(30)  NOT NULL,
    correlation_id    CHAR(36)     NOT NULL,
    status            VARCHAR(40)  NOT NULL,
    created_at        DATETIME(6)  NOT NULL,
    updated_at        DATETIME(6)  NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_triage_sessions_protocolo (protocolo),
    INDEX idx_triage_sessions_law_firm_id (law_firm_id),
    INDEX idx_triage_sessions_api_credential_id (api_credential_id),
    INDEX idx_triage_sessions_status (status),
    INDEX idx_triage_sessions_correlation_id (correlation_id),
    CONSTRAINT fk_triage_sessions_law_firm FOREIGN KEY (law_firm_id)
        REFERENCES law_firms(id),
    CONSTRAINT fk_triage_sessions_api_credential FOREIGN KEY (api_credential_id)
        REFERENCES api_credentials(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE legal_cases (
    id             CHAR(36)     NOT NULL,
    session_id     CHAR(36)     NOT NULL,
    titulo         VARCHAR(255) NOT NULL,
    area_juridica  VARCHAR(30)  NOT NULL,
    tipo_caso      VARCHAR(50)  NOT NULL,
    created_at     DATETIME(6)  NOT NULL,
    updated_at     DATETIME(6)  NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_legal_cases_session_id (session_id),
    INDEX idx_legal_cases_area_juridica (area_juridica),
    INDEX idx_legal_cases_tipo_caso (tipo_caso),
    CONSTRAINT fk_legal_cases_session FOREIGN KEY (session_id)
        REFERENCES triage_sessions(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- Ajuste 4: removida a constraint UNIQUE em session_id para permitir
-- múltiplos destinatários cadastrados por sessão (RF11 fala em "responsáveis",
-- no plural).
CREATE TABLE notification_recipients (
    id                  CHAR(36)     NOT NULL,
    session_id           CHAR(36)     NOT NULL,
    contact_id           CHAR(36),
    nome                 VARCHAR(200) NOT NULL,
    email                VARCHAR(200),
    telefone             VARCHAR(30),
    canal_preferencial   VARCHAR(20)  NOT NULL,
    PRIMARY KEY (id),
    INDEX idx_notification_recipients_session_id (session_id),
    INDEX idx_notification_recipients_contact_id (contact_id),
    CONSTRAINT fk_notification_recipients_session FOREIGN KEY (session_id)
        REFERENCES triage_sessions(id) ON DELETE CASCADE,
    CONSTRAINT fk_notification_recipients_contact FOREIGN KEY (contact_id)
        REFERENCES law_firm_contacts(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- Ajuste 1 e 2: attachment_group_id + part_number para suportar anexos
-- fragmentados (ex: WhatsApp longo enviado em múltiplos envios), e campos
-- de retenção para comprovar a remoção do documento bruto (RNF04).
CREATE TABLE legal_documents (
    id                       CHAR(36)     NOT NULL,
    session_id               CHAR(36)     NOT NULL,
    attachment_group_id      CHAR(36)     NOT NULL,
    part_number              INT          NOT NULL DEFAULT 1,
    nome_arquivo_original    VARCHAR(255) NOT NULL,
    tipo_documento           VARCHAR(30)  NOT NULL,
    content_type             VARCHAR(100) NOT NULL,
    tamanho_bytes            BIGINT,
    raw_bucket               VARCHAR(200) NOT NULL,
    raw_object_key           VARCHAR(500) NOT NULL,
    raw_deleted_at           DATETIME(6),
    retention_expires_at     DATETIME(6),
    processed_bucket         VARCHAR(200),
    processed_object_key     VARCHAR(500),
    status                   VARCHAR(40)  NOT NULL,
    error_message            VARCHAR(1000),
    created_at               DATETIME(6)  NOT NULL,
    updated_at               DATETIME(6)  NOT NULL,
    PRIMARY KEY (id),
    INDEX idx_legal_documents_session_id (session_id),
    INDEX idx_legal_documents_attachment_group_id (attachment_group_id),
    INDEX idx_legal_documents_status (status),
    INDEX idx_legal_documents_tipo_documento (tipo_documento),
    CONSTRAINT fk_legal_documents_session FOREIGN KEY (session_id)
        REFERENCES triage_sessions(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- attachment_group_id: gap de schema identificado na spec da Fase 2 (seção 3) —
-- identifica a etapa quando ela é em nível de grupo (attachment_grouping/
-- evidence_summarization), e não de documento individual (ocr/anonymization).
CREATE TABLE processing_steps (
    id                    CHAR(36)     NOT NULL,
    session_id            CHAR(36)     NOT NULL,
    document_id           CHAR(36),
    attachment_group_id   CHAR(36),
    step_name             VARCHAR(50)  NOT NULL,
    status                VARCHAR(40)  NOT NULL,
    started_at            DATETIME(6),
    finished_at           DATETIME(6),
    error_message         VARCHAR(1000),
    created_at            DATETIME(6)  NOT NULL,
    updated_at            DATETIME(6)  NOT NULL,
    PRIMARY KEY (id),
    INDEX idx_processing_steps_session_id (session_id),
    INDEX idx_processing_steps_document_id (document_id),
    INDEX idx_processing_steps_attachment_group_id (attachment_group_id),
    INDEX idx_processing_steps_step_name (step_name),
    INDEX idx_processing_steps_status (status),
    CONSTRAINT fk_processing_steps_session FOREIGN KEY (session_id)
        REFERENCES triage_sessions(id) ON DELETE CASCADE,
    CONSTRAINT fk_processing_steps_document FOREIGN KEY (document_id)
        REFERENCES legal_documents(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- T5 (spec Fase 2, seção 7) — cache de consulta de jurisprudência.
CREATE TABLE jurisprudence_cache (
    id                CHAR(36)     NOT NULL,
    query_hash        VARCHAR(64)  NOT NULL,
    tese_juridica     VARCHAR(500) NOT NULL,
    area_juridica     VARCHAR(30)  NOT NULL,
    response_payload  TEXT         NOT NULL,
    created_at        DATETIME(6)  NOT NULL,
    expires_at        DATETIME(6)  NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_jurisprudence_cache_query_hash (query_hash),
    INDEX idx_jurisprudence_cache_expires_at (expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- Fonte da verdade para toda chamada de ferramenta feita pelo MCP
-- (OCR, anonimização, agrupamento, resumo, jurisprudência, notificação).
CREATE TABLE ai_tool_calls (
    id                CHAR(36)     NOT NULL,
    session_id        CHAR(36)     NOT NULL,
    tool_name         VARCHAR(80)  NOT NULL,
    provider          VARCHAR(80),
    request_payload   TEXT,
    response_payload  TEXT,
    status            VARCHAR(40)  NOT NULL,
    error_message     VARCHAR(1000),
    started_at        DATETIME(6)  NOT NULL,
    finished_at       DATETIME(6),
    PRIMARY KEY (id),
    INDEX idx_ai_tool_calls_session_id (session_id),
    INDEX idx_ai_tool_calls_tool_name (tool_name),
    INDEX idx_ai_tool_calls_status (status),
    CONSTRAINT fk_ai_tool_calls_session FOREIGN KEY (session_id)
        REFERENCES triage_sessions(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- Ajuste 3: jurisprudence_used (boolean) removido. Em seu lugar,
-- jurisprudence_call_id aponta para o registro real da chamada em
-- ai_tool_calls (tool_name = 'jurisprudence_query'), evitando duas fontes
-- de verdade divergentes sobre se a consulta foi feita.
CREATE TABLE triage_results (
    id                     CHAR(36)     NOT NULL,
    session_id             CHAR(36)     NOT NULL,
    result_bucket          VARCHAR(200) NOT NULL,
    result_object_key      VARCHAR(500) NOT NULL,
    summary_object_key     VARCHAR(500),
    jurisprudence_call_id  CHAR(36),
    created_at             DATETIME(6)  NOT NULL,
    updated_at             DATETIME(6)  NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_triage_results_session_id (session_id),
    CONSTRAINT fk_triage_results_session FOREIGN KEY (session_id)
        REFERENCES triage_sessions(id) ON DELETE CASCADE,
    CONSTRAINT fk_triage_results_jurisprudence_call FOREIGN KEY (jurisprudence_call_id)
        REFERENCES ai_tool_calls(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE notification_deliveries (
    id                    CHAR(36)     NOT NULL,
    session_id             CHAR(36)     NOT NULL,
    recipient_id           CHAR(36)     NOT NULL,
    canal                  VARCHAR(20)  NOT NULL,
    destino                VARCHAR(200) NOT NULL,
    status                 VARCHAR(40)  NOT NULL,
    provider               VARCHAR(50),
    provider_message_id    VARCHAR(200),
    error_message          VARCHAR(1000),
    sent_at                DATETIME(6),
    created_at             DATETIME(6)  NOT NULL,
    updated_at             DATETIME(6)  NOT NULL,
    PRIMARY KEY (id),
    INDEX idx_notification_deliveries_session_id (session_id),
    INDEX idx_notification_deliveries_recipient_id (recipient_id),
    INDEX idx_notification_deliveries_status (status),
    INDEX idx_notification_deliveries_canal (canal),
    CONSTRAINT fk_notification_deliveries_session FOREIGN KEY (session_id)
        REFERENCES triage_sessions(id) ON DELETE CASCADE,
    CONSTRAINT fk_notification_deliveries_recipient FOREIGN KEY (recipient_id)
        REFERENCES notification_recipients(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE audit_events (
    id              CHAR(36)     NOT NULL,
    session_id      CHAR(36),
    law_firm_id      CHAR(36),
    correlation_id  CHAR(36),
    event_type      VARCHAR(50)  NOT NULL,
    description     VARCHAR(500) NOT NULL,
    payload_json    TEXT,
    created_at      DATETIME(6)  NOT NULL,
    PRIMARY KEY (id),
    INDEX idx_audit_session_id (session_id),
    INDEX idx_audit_law_firm_id (law_firm_id),
    INDEX idx_audit_correlation_id (correlation_id),
    INDEX idx_audit_event_type (event_type),
    CONSTRAINT fk_audit_events_session FOREIGN KEY (session_id)
        REFERENCES triage_sessions(id) ON DELETE SET NULL,
    CONSTRAINT fk_audit_events_law_firm FOREIGN KEY (law_firm_id)
        REFERENCES law_firms(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- Injestão de dados
-- Seed de conveniência para ambiente local/HO (mesmo padrão do V2 anterior do
-- projeto): um escritório e uma credencial de API já ativa, para permitir
-- testar os endpoints sem precisar de um fluxo de cadastro (fora do escopo
-- desta fase). NÃO aplicar em produção.
--
-- Token de teste: "dev-local-token"
-- (token_hash = SHA-256 hex do token acima)

INSERT INTO law_firms (id, nome, cnpj, email_contato, telefone, status, created_at, updated_at)
VALUES (
    '11111111-1111-1111-1111-111111111111',
    'Escritório de Testes TriAIge',
    '00000000000100',
    'contato@escritorio-teste.example.com',
    '+55 11 90000-0000',
    'ACTIVE',
    NOW(6),
    NOW(6)
);

INSERT INTO api_credentials (id, law_firm_id, name, token_hash, status, last_used_at, expires_at, created_at, updated_at)
VALUES (
    '22222222-2222-2222-2222-222222222222',
    '11111111-1111-1111-1111-111111111111',
    'Credencial de desenvolvimento local',
    'a8b209467de49495388ff13632517e447d243fb5d2f04534e4c2110047c141a2',
    'ACTIVE',
    NULL,
    NULL,
    NOW(6),
    NOW(6)
);