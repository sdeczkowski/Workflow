# Workflow
System służący do zarządzania zadaniami
## Pliki
* create.sql - Skrypt tworzący schematy oraz tabele
* proc.sql - Skrypt tworzący procedury składowe
* createddl.sql - Skrypt zbiorczy = create.sql + proc.sql
* insert.sql - Skrypt generujący po 100 testowych userów dla 10 podmiotów oraz 1000 zadań dla każdego użytkownika.
## Architektura
Dla każdego z podmiotów został utworzony oddzielny schemat, aby zoptymalizować jednoczesne korzystanie z tabel przez różne podmioty. Zostały zaimplementowane indeksy w celu optymalizacji zapytań SELECT
