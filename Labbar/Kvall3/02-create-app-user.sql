-- =============================================================================
-- Steg 4 - Ge webbappens identitet åtkomst i databasen
--
-- Körs MOT databasen "customers", inloggad som Entra-admin (dig):
--   * VS Code (mssql-tillägget): anslut med "Microsoft Entra ID" och kör filen
--   * SSMS: Authentication = "Microsoft Entra MFA"
--   * eller: ./02-create-app-user.ps1  (genererar SQL:en och kör den med sqlcmd)
--
-- Byt <APPNAMN> mot namnet på webbappen (variabeln $app i lab-vars.ps1).
-- Databasanvändaren HETER som webbappens Managed Identity.
-- =============================================================================

CREATE USER [<APPNAMN>] FROM EXTERNAL PROVIDER;

-- Minsta behörighet: läsa och skriva data. Appen får INTE ändra schemat.
ALTER ROLE db_datareader ADD MEMBER [<APPNAMN>];
ALTER ROLE db_datawriter ADD MEMBER [<APPNAMN>];

-- Kontroll:
SELECT dp.name, dp.type_desc, r.name AS role_name
FROM sys.database_principals dp
LEFT JOIN sys.database_role_members m ON m.member_principal_id = dp.principal_id
LEFT JOIN sys.database_principals r ON r.principal_id = m.role_principal_id
WHERE dp.type = 'E';
