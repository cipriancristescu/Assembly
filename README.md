# Tema - Arhitectura Sistemelor de Calcul

Acest repository conține implementarea temei la disciplina **Arhitectura Sistemelor de Calcul**
##  Conținut

- `0.s` – implementarea pentru **sistemul de gestiune unidimensional** al memoriei.
- `1.s` – implementarea pentru **sistemul de gestiune bidimensional** al memoriei.

##  Descriere temă

Scopul temei este implementarea unui modul de gestiune a dispozitivului de stocare pentru un sistem de operare minimalist, în două variante:

1. **Memorie unidimensională**
2. **Memorie bidimensională**

### 1️ Cerința 0x00 – Memorie unidimensională

- Memorie de 8MB împărțită în blocuri de 8kB.
- Operații implementate:
  - `ADD` – adaugă un fișier (alocat doar contiguu).
  - `GET` – returnează intervalul de blocuri al unui fișier.
  - `DELETE` – șterge fișierul și eliberează blocurile.
  - `DEFRAGMENTATION` – compactează fișierele pentru a elimina golurile.

> Blocurile sunt reprezentate ca o listă unidimensională de întregi (descriptorii fișierelor), 0 însemnând bloc liber.

### 2️Cerința 0x01 – Memorie bidimensională

- Memorie de 8MB × 8MB, reprezentată ca o matrice de blocuri.
- Operații implementate:
  - `ADD` – adaugă fișiere pe rânduri, în poziții contigue.
  - `GET` – returnează coordonatele ((startX, startY), (endX, endY)).
  - `DELETE` – eliberează blocurile ocupate de fișier.
  - `DEFRAGMENTATION` – compactează fișierele spre colțul stânga-sus.
  - `CONCRETE` – încarcă fișiere reale de pe disc.

> Blocurile libere sunt marcate cu `0`.

## Rulare & Testare

Pentru testarea codului, se recomandă folosirea unui fișier de input:

```bash
./task00 < input.txt
./task01 < input.txt
