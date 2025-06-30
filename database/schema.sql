-- Schemat bazy danych dla kalkulatora emerytalnego
-- Dane o inflacji dla różnych walut i krajów

-- Tabela walut i krajów
CREATE TABLE IF NOT EXISTS currencies (
    id SERIAL PRIMARY KEY,
    currency_code VARCHAR(3) NOT NULL UNIQUE,
    country_code VARCHAR(2) NOT NULL,
    country_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela danych o inflacji
CREATE TABLE IF NOT EXISTS inflation_data (
    id SERIAL PRIMARY KEY,
    currency_id INTEGER NOT NULL REFERENCES currencies(id) ON DELETE CASCADE,
    year INTEGER NOT NULL,
    month INTEGER NOT NULL CHECK (month >= 1 AND month <= 12),
    inflation_rate DECIMAL(8,4) NOT NULL, -- Stopa inflacji w procentach (np. 2.5%)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(currency_id, year, month)
);

-- Indeksy dla lepszej wydajności
CREATE INDEX IF NOT EXISTS idx_inflation_currency_year_month ON inflation_data(currency_id, year, month);
CREATE INDEX IF NOT EXISTS idx_currencies_code ON currencies(currency_code);

-- Funkcja do automatycznego aktualizowania updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggery do automatycznego aktualizowania updated_at
CREATE TRIGGER update_currencies_updated_at BEFORE UPDATE ON currencies 
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_inflation_data_updated_at BEFORE UPDATE ON inflation_data 
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Przykładowe dane
INSERT INTO currencies (currency_code, country_code, country_name) VALUES
('PLN', 'PL', 'Polska'),
('USD', 'US', 'Stany Zjednoczone'),
('EUR', 'EU', 'Unia Europejska'),
('GBP', 'GB', 'Wielka Brytania'),
('JPY', 'JP', 'Japonia'),
('CHF', 'CH', 'Szwajcaria'),
('CAD', 'CA', 'Kanada'),
('AUD', 'AU', 'Australia')
ON CONFLICT (currency_code) DO NOTHING;

-- Przykładowe dane o inflacji dla PLN (2020-2023)
INSERT INTO inflation_data (currency_id, year, month, inflation_rate) VALUES
((SELECT id FROM currencies WHERE currency_code = 'PLN'), 2020, 1, 4.3),
((SELECT id FROM currencies WHERE currency_code = 'PLN'), 2020, 2, 4.7),
((SELECT id FROM currencies WHERE currency_code = 'PLN'), 2020, 3, 4.6),
((SELECT id FROM currencies WHERE currency_code = 'PLN'), 2020, 4, 3.4),
((SELECT id FROM currencies WHERE currency_code = 'PLN'), 2020, 5, 3.4),
((SELECT id FROM currencies WHERE currency_code = 'PLN'), 2020, 6, 3.3),
((SELECT id FROM currencies WHERE currency_code = 'PLN'), 2020, 7, 2.9),
((SELECT id FROM currencies WHERE currency_code = 'PLN'), 2020, 8, 2.9),
((SELECT id FROM currencies WHERE currency_code = 'PLN'), 2020, 9, 3.2),
((SELECT id FROM currencies WHERE currency_code = 'PLN'), 2020, 10, 3.1),
((SELECT id FROM currencies WHERE currency_code = 'PLN'), 2020, 11, 2.4),
((SELECT id FROM currencies WHERE currency_code = 'PLN'), 2020, 12, 2.4),
((SELECT id FROM currencies WHERE currency_code = 'PLN'), 2021, 1, 2.7),
((SELECT id FROM currencies WHERE currency_code = 'PLN'), 2021, 2, 2.4),
((SELECT id FROM currencies WHERE currency_code = 'PLN'), 2021, 3, 3.2),
((SELECT id FROM currencies WHERE currency_code = 'PLN'), 2021, 4, 4.3),
((SELECT id FROM currencies WHERE currency_code = 'PLN'), 2021, 5, 4.7),
((SELECT id FROM currencies WHERE currency_code = 'PLN'), 2021, 6, 4.4),
((SELECT id FROM currencies WHERE currency_code = 'PLN'), 2021, 7, 5.0),
((SELECT id FROM currencies WHERE currency_code = 'PLN'), 2021, 8, 5.5),
((SELECT id FROM currencies WHERE currency_code = 'PLN'), 2021, 9, 5.9),
((SELECT id FROM currencies WHERE currency_code = 'PLN'), 2021, 10, 6.8),
((SELECT id FROM currencies WHERE currency_code = 'PLN'), 2021, 11, 7.7),
((SELECT id FROM currencies WHERE currency_code = 'PLN'), 2021, 12, 8.6),
((SELECT id FROM currencies WHERE currency_code = 'PLN'), 2022, 1, 9.4),
((SELECT id FROM currencies WHERE currency_code = 'PLN'), 2022, 2, 8.5),
((SELECT id FROM currencies WHERE currency_code = 'PLN'), 2022, 3, 10.9),
((SELECT id FROM currencies WHERE currency_code = 'PLN'), 2022, 4, 12.4),
((SELECT id FROM currencies WHERE currency_code = 'PLN'), 2022, 5, 13.9),
((SELECT id FROM currencies WHERE currency_code = 'PLN'), 2022, 6, 15.6),
((SELECT id FROM currencies WHERE currency_code = 'PLN'), 2022, 7, 15.6),
((SELECT id FROM currencies WHERE currency_code = 'PLN'), 2022, 8, 16.1),
((SELECT id FROM currencies WHERE currency_code = 'PLN'), 2022, 9, 17.2),
((SELECT id FROM currencies WHERE currency_code = 'PLN'), 2022, 10, 17.9),
((SELECT id FROM currencies WHERE currency_code = 'PLN'), 2022, 11, 17.4),
((SELECT id FROM currencies WHERE currency_code = 'PLN'), 2022, 12, 16.6),
((SELECT id FROM currencies WHERE currency_code = 'PLN'), 2023, 1, 16.6),
((SELECT id FROM currencies WHERE currency_code = 'PLN'), 2023, 2, 18.4),
((SELECT id FROM currencies WHERE currency_code = 'PLN'), 2023, 3, 16.1),
((SELECT id FROM currencies WHERE currency_code = 'PLN'), 2023, 4, 14.7),
((SELECT id FROM currencies WHERE currency_code = 'PLN'), 2023, 5, 13.0),
((SELECT id FROM currencies WHERE currency_code = 'PLN'), 2023, 6, 11.5),
((SELECT id FROM currencies WHERE currency_code = 'PLN'), 2023, 7, 10.8),
((SELECT id FROM currencies WHERE currency_code = 'PLN'), 2023, 8, 10.1),
((SELECT id FROM currencies WHERE currency_code = 'PLN'), 2023, 9, 8.2),
((SELECT id FROM currencies WHERE currency_code = 'PLN'), 2023, 10, 6.6),
((SELECT id FROM currencies WHERE currency_code = 'PLN'), 2023, 11, 6.5),
((SELECT id FROM currencies WHERE currency_code = 'PLN'), 2023, 12, 6.2)
ON CONFLICT (currency_id, year, month) DO NOTHING;

-- Przykładowe dane o inflacji dla USD (2020-2023)
INSERT INTO inflation_data (currency_id, year, month, inflation_rate) VALUES
((SELECT id FROM currencies WHERE currency_code = 'USD'), 2020, 1, 2.5),
((SELECT id FROM currencies WHERE currency_code = 'USD'), 2020, 2, 2.3),
((SELECT id FROM currencies WHERE currency_code = 'USD'), 2020, 3, 1.5),
((SELECT id FROM currencies WHERE currency_code = 'USD'), 2020, 4, 0.3),
((SELECT id FROM currencies WHERE currency_code = 'USD'), 2020, 5, 0.1),
((SELECT id FROM currencies WHERE currency_code = 'USD'), 2020, 6, 0.6),
((SELECT id FROM currencies WHERE currency_code = 'USD'), 2020, 7, 1.0),
((SELECT id FROM currencies WHERE currency_code = 'USD'), 2020, 8, 1.3),
((SELECT id FROM currencies WHERE currency_code = 'USD'), 2020, 9, 1.4),
((SELECT id FROM currencies WHERE currency_code = 'USD'), 2020, 10, 1.2),
((SELECT id FROM currencies WHERE currency_code = 'USD'), 2020, 11, 1.2),
((SELECT id FROM currencies WHERE currency_code = 'USD'), 2020, 12, 1.4),
((SELECT id FROM currencies WHERE currency_code = 'USD'), 2021, 1, 1.4),
((SELECT id FROM currencies WHERE currency_code = 'USD'), 2021, 2, 1.7),
((SELECT id FROM currencies WHERE currency_code = 'USD'), 2021, 3, 2.6),
((SELECT id FROM currencies WHERE currency_code = 'USD'), 2021, 4, 4.2),
((SELECT id FROM currencies WHERE currency_code = 'USD'), 2021, 5, 5.0),
((SELECT id FROM currencies WHERE currency_code = 'USD'), 2021, 6, 5.4),
((SELECT id FROM currencies WHERE currency_code = 'USD'), 2021, 7, 5.4),
((SELECT id FROM currencies WHERE currency_code = 'USD'), 2021, 8, 5.3),
((SELECT id FROM currencies WHERE currency_code = 'USD'), 2021, 9, 5.4),
((SELECT id FROM currencies WHERE currency_code = 'USD'), 2021, 10, 6.2),
((SELECT id FROM currencies WHERE currency_code = 'USD'), 2021, 11, 6.8),
((SELECT id FROM currencies WHERE currency_code = 'USD'), 2021, 12, 7.0),
((SELECT id FROM currencies WHERE currency_code = 'USD'), 2022, 1, 7.5),
((SELECT id FROM currencies WHERE currency_code = 'USD'), 2022, 2, 7.9),
((SELECT id FROM currencies WHERE currency_code = 'USD'), 2022, 3, 8.5),
((SELECT id FROM currencies WHERE currency_code = 'USD'), 2022, 4, 8.3),
((SELECT id FROM currencies WHERE currency_code = 'USD'), 2022, 5, 8.6),
((SELECT id FROM currencies WHERE currency_code = 'USD'), 2022, 6, 9.1),
((SELECT id FROM currencies WHERE currency_code = 'USD'), 2022, 7, 8.5),
((SELECT id FROM currencies WHERE currency_code = 'USD'), 2022, 8, 8.3),
((SELECT id FROM currencies WHERE currency_code = 'USD'), 2022, 9, 8.2),
((SELECT id FROM currencies WHERE currency_code = 'USD'), 2022, 10, 7.7),
((SELECT id FROM currencies WHERE currency_code = 'USD'), 2022, 11, 7.1),
((SELECT id FROM currencies WHERE currency_code = 'USD'), 2022, 12, 6.5),
((SELECT id FROM currencies WHERE currency_code = 'USD'), 2023, 1, 6.4),
((SELECT id FROM currencies WHERE currency_code = 'USD'), 2023, 2, 6.0),
((SELECT id FROM currencies WHERE currency_code = 'USD'), 2023, 3, 5.0),
((SELECT id FROM currencies WHERE currency_code = 'USD'), 2023, 4, 4.9),
((SELECT id FROM currencies WHERE currency_code = 'USD'), 2023, 5, 4.0),
((SELECT id FROM currencies WHERE currency_code = 'USD'), 2023, 6, 3.0),
((SELECT id FROM currencies WHERE currency_code = 'USD'), 2023, 7, 3.2),
((SELECT id FROM currencies WHERE currency_code = 'USD'), 2023, 8, 3.7),
((SELECT id FROM currencies WHERE currency_code = 'USD'), 2023, 9, 3.7),
((SELECT id FROM currencies WHERE currency_code = 'USD'), 2023, 10, 3.2),
((SELECT id FROM currencies WHERE currency_code = 'USD'), 2023, 11, 3.1),
((SELECT id FROM currencies WHERE currency_code = 'USD'), 2023, 12, 3.4)
ON CONFLICT (currency_id, year, month) DO NOTHING;