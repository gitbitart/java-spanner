/*
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

SELECT PARENT.TABLE_CATALOG AS PKTABLE_CAT, PARENT.TABLE_SCHEMA AS PKTABLE_SCHEM,
       PARENT.TABLE_NAME AS PKTABLE_NAME, PARENT_INDEX_COLUMNS.COLUMN_NAME AS PKCOLUMN_NAME,
       CHILD.TABLE_CATALOG AS FKTABLE_CAT, CHILD.TABLE_SCHEMA AS FKTABLE_SCHEM,
       CHILD.TABLE_NAME AS FKTABLE_NAME, PARENT_INDEX_COLUMNS.COLUMN_NAME AS FKCOLUMN_NAME,
       PARENT_INDEX_COLUMNS.ORDINAL_POSITION AS KEY_SEQ,
       1 AS UPDATE_RULE, -- 1 = importedKeyRestrict
       CASE WHEN CHILD.ON_DELETE_ACTION='CASCADE' THEN 0 ELSE 1 END AS DELETE_RULE, -- 0 = cascade
       NULL AS FK_NAME, 'PRIMARY_KEY' AS PK_NAME,
       7 AS DEFERRABILITY -- 7 = importedKeyNotDeferrable
FROM INFORMATION_SCHEMA.TABLES PARENT
INNER JOIN INFORMATION_SCHEMA.TABLES CHILD ON CHILD.PARENT_TABLE_NAME=PARENT.TABLE_NAME
INNER JOIN INFORMATION_SCHEMA.INDEX_COLUMNS PARENT_INDEX_COLUMNS ON
           PARENT_INDEX_COLUMNS.TABLE_NAME=PARENT.TABLE_NAME
       AND PARENT_INDEX_COLUMNS.INDEX_NAME='PRIMARY_KEY'
WHERE UPPER(PARENT.TABLE_CATALOG) LIKE ?
  AND UPPER(PARENT.TABLE_SCHEMA) LIKE ?
  AND UPPER(PARENT.TABLE_NAME) LIKE ?
ORDER BY CHILD.TABLE_CATALOG, CHILD.TABLE_SCHEMA, CHILD.TABLE_NAME, PARENT_INDEX_COLUMNS.ORDINAL_POSITION