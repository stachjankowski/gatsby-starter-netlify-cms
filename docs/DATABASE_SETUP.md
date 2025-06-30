# Konfiguracja Bazy Danych

## Wymagania

- PostgreSQL 12 lub nowszy
- Dostęp do bazy danych z funkcji Netlify

## Konfiguracja środowiska

### 1. Zmienne środowiskowe

Dodaj następujące zmienne środowiskowe w panelu Netlify:

```bash
DATABASE_URL=postgresql://username:password@host:port/database_name
NODE_ENV=production
```

Dla lokalnego developmentu, stwórz plik `.env`:

```bash
DATABASE_URL=postgresql://localhost:5432/kalkulatoremerytalny
NODE_ENV=development
```

### 2. Instalacja zależności

Po dodaniu `pg` do `package.json`, zainstaluj zależności:

```bash
npm install
# lub
yarn install
```

## Konfiguracja bazy danych

### 1. Utworzenie bazy danych

```sql
CREATE DATABASE kalkulatoremerytalny;
```

### 2. Uruchomienie schematu

Wykonaj skrypt SQL ze schematu:

```bash
psql -d kalkulatoremerytalny -f database/schema.sql
```

Lub skopiuj zawartość pliku `database/schema.sql` i wykonaj w kliencie PostgreSQL.

### 3. Weryfikacja instalacji

Sprawdź czy tabele zostały utworzone:

```sql
\dt

-- Powinno wyświetlić:
--  Schema |     Name      | Type  | Owner 
-- --------+---------------+-------+-------
--  public | currencies    | table | user
--  public | inflation_data| table | user
```

Sprawdź przykładowe dane:

```sql
SELECT COUNT(*) FROM currencies;
-- Powinno zwrócić: 8

SELECT COUNT(*) FROM inflation_data;
-- Powinno zwrócić: 96 (48 dla PLN + 48 dla USD)
```

## Struktura tabel

### Tabela `currencies`
```sql
-- Przechowuje informacje o walutach i krajach
id            SERIAL PRIMARY KEY
currency_code VARCHAR(3) UNIQUE  -- Kod waluty (PLN, USD, etc.)
country_code  VARCHAR(2)         -- Kod kraju (PL, US, etc.)
country_name  VARCHAR(100)       -- Nazwa kraju
created_at    TIMESTAMP
updated_at    TIMESTAMP
```

### Tabela `inflation_data`
```sql
-- Przechowuje dane o inflacji
id             SERIAL PRIMARY KEY
currency_id    INTEGER            -- FK do currencies
year           INTEGER            -- Rok
month          INTEGER            -- Miesiąc (1-12)
inflation_rate DECIMAL(8,4)       -- Stopa inflacji w %
created_at     TIMESTAMP
updated_at     TIMESTAMP
```

## Dodawanie nowych danych

### Dodawanie nowej waluty

```sql
INSERT INTO currencies (currency_code, country_code, country_name) 
VALUES ('CZK', 'CZ', 'Republika Czeska');
```

### Dodawanie danych o inflacji

```sql
-- Pojedynczy wpis
INSERT INTO inflation_data (currency_id, year, month, inflation_rate) 
VALUES (
  (SELECT id FROM currencies WHERE currency_code = 'CZK'),
  2023,
  12,
  8.5
);

-- Wiele wpisów naraz
INSERT INTO inflation_data (currency_id, year, month, inflation_rate) VALUES
((SELECT id FROM currencies WHERE currency_code = 'CZK'), 2023, 10, 7.8),
((SELECT id FROM currencies WHERE currency_code = 'CZK'), 2023, 11, 8.1),
((SELECT id FROM currencies WHERE currency_code = 'CZK'), 2023, 12, 8.5);
```

## Zapytania do analizy danych

### Sprawdzenie dostępnych walut
```sql
SELECT currency_code, country_name, 
       COUNT(id.id) as data_points,
       MIN(CONCAT(id.year, '-', LPAD(id.month::text, 2, '0'))) as earliest_data,
       MAX(CONCAT(id.year, '-', LPAD(id.month::text, 2, '0'))) as latest_data
FROM currencies c
LEFT JOIN inflation_data id ON c.id = id.currency_id
GROUP BY c.id, currency_code, country_name
ORDER BY currency_code;
```

### Statystyki dla konkretnej waluty
```sql
SELECT 
  c.currency_code,
  c.country_name,
  COUNT(id.id) as total_months,
  ROUND(AVG(id.inflation_rate), 4) as average_inflation,
  ROUND(STDDEV(id.inflation_rate), 4) as standard_deviation,
  MIN(id.inflation_rate) as min_inflation,
  MAX(id.inflation_rate) as max_inflation
FROM currencies c
JOIN inflation_data id ON c.id = id.currency_id
WHERE c.currency_code = 'PLN'
GROUP BY c.id, c.currency_code, c.country_name;
```

### Inflacja w czasie (ostatnie 12 miesięcy)
```sql
SELECT 
  CONCAT(id.year, '-', LPAD(id.month::text, 2, '0')) as period,
  id.inflation_rate
FROM inflation_data id
JOIN currencies c ON id.currency_id = c.id
WHERE c.currency_code = 'PLN'
ORDER BY id.year DESC, id.month DESC
LIMIT 12;
```

## Backup i restore

### Backup
```bash
pg_dump kalkulatoremerytalny > backup.sql
```

### Restore
```bash
psql kalkulatoremerytalny < backup.sql
```

## Monitorowanie wydajności

### Sprawdzenie indeksów
```sql
SELECT 
  schemaname,
  tablename,
  indexname,
  indexdef
FROM pg_indexes 
WHERE tablename IN ('currencies', 'inflation_data');
```

### Analiza wykonania zapytań
```sql
EXPLAIN ANALYZE 
SELECT 
  c.currency_code,
  AVG(id.inflation_rate)
FROM currencies c
JOIN inflation_data id ON c.id = id.currency_id
WHERE c.currency_code = 'PLN'
GROUP BY c.currency_code;
```

## Hosting bazy danych

### Zalecane serwisy
1. **ElephantSQL** - bezpłatny tier PostgreSQL
2. **Heroku Postgres** - łatwa integracja
3. **AWS RDS** - skalowalne rozwiązanie
4. **Supabase** - nowoczesna alternatywa z API

### Przykład konfiguracji dla ElephantSQL
1. Załóż konto na elephantsql.com
2. Utwórz nową instancję
3. Skopiuj URL połączenia
4. Dodaj URL jako `DATABASE_URL` w zmiennych środowiskowych Netlify