BEGIN;

-- To-Do List View

SELECT dropIfExists('VIEW', 'todo', 'api');
CREATE OR REPLACE VIEW api.todo AS
  SELECT
    todoitem_id AS task_number,
    usr_username AS assigned_to,
    todoitem_name AS task_name,
    todoitem_seq AS sequence_number,
    incdt_number AS incident,
    ophead_name AS opportunity,
    crmacct_number AS account,
    formatdate(todoitem_due_date) AS date_due,
    formatdate(todoitem_assigned_date) AS date_assigned,
    formatdate(todoitem_start_date) AS date_started,
    formatdate(todoitem_completed_date) AS date_completed,
    CASE
      WHEN todoitem_status = 'P' THEN
        'Pending Input'
      WHEN todoitem_status = 'D' THEN
        'Deferred'
      ELSE
        'Neither'
    END AS status,
    todoitem_active AS active,
    todoitem_description AS description,
    todoitem_notes AS notes
    FROM todoitem
       LEFT OUTER JOIN usr ON (usr_id=todoitem_usr_id)
       LEFT OUTER JOIN incdt ON (incdt_id=todoitem_incdt_id)
       LEFT OUTER JOIN ophead ON (ophead_id=todoitem_ophead_id)
       LEFT OUTER JOIN crmacct ON (crmacct_id=todoitem_crmacct_id);

GRANT ALL ON TABLE api.todo TO openmfg;
COMMENT ON VIEW api.todo IS 'To-Do List';

--Rules

CREATE OR REPLACE RULE "_INSERT" AS
    ON INSERT TO api.todo DO INSTEAD

  SELECT createTodoItem(
    getUsrId(NEW.assigned_to),
    COALESCE(NEW.task_name, ''),
    COALESCE(NEW.description, ''),
    getIncidentId(NEW.incident),
    COALESCE(getIncdtCrmAcctId(NEW.incident), getCrmAcctId(NEW.account)),
    getOpHeadId(NEW.opportunity),
    CASE
      WHEN (NEW.date_started > '') THEN
        NEW.date_started::DATE
      ELSE
        NULL
    END,
    CASE
      WHEN (NEW.date_due > '') THEN
        NEW.date_due::DATE
      ELSE
        NULL
    END,
    CASE
      WHEN NEW.status = 'Pending Input' THEN
        'P'
      WHEN NEW.status = 'Deferred' THEN
        'D'
      ELSE
        'N'
    END,
    CASE
      WHEN (NEW.date_assigned > '') THEN
        NEW.date_assigned::DATE
      ELSE
        NULL
    END,
    CASE
      WHEN (NEW.date_completed > '') THEN
        NEW.date_completed::DATE
      ELSE
        NULL
    END,
    NEW.sequence_number,
    COALESCE(NEW.notes, '')
    );

CREATE OR REPLACE RULE "_UPDATE" AS 
    ON UPDATE TO api.todo DO INSTEAD

  SELECT updateTodoItem(
    OLD.task_number,
    getUsrId(OLD.assigned_to),
    NEW.task_name,
    NEW.description,
    getIncidentId(NEW.incident),
    COALESCE(getIncdtCrmAcctId(NEW.incident), getCrmAcctId(NEW.account)),
    getOpHeadId(NEW.opportunity),
    CASE
      WHEN (NEW.date_started > '') THEN
        NEW.date_started::DATE
      ELSE
        NULL
    END,
    CASE
      WHEN (NEW.date_due > '') THEN
        NEW.date_due::DATE
      ELSE
        NULL
    END,
    CASE
      WHEN NEW.status = 'Pending Input' THEN
        'P'
      WHEN NEW.status = 'Deferred' THEN
        'D'
      WHEN NEW.status = 'Neither' THEN
        'N'
      ELSE
        NULL
    END,
    CASE
      WHEN (NEW.date_assigned > '') THEN
        NEW.date_assigned::DATE
      ELSE
        NULL
    END,
    CASE
      WHEN (NEW.date_completed > '') THEN
        NEW.date_completed::DATE
      ELSE
        NULL
    END,
    OLD.sequence_number,
    NEW.notes,
    NEW.active
    );
           
CREATE OR REPLACE RULE "_DELETE" AS 
    ON DELETE TO api.todo DO INSTEAD

  SELECT deleteTodoItem(OLD.task_number);

COMMIT;
