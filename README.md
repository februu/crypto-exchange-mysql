# Crypto Exchange MySQL

Projekt zaliczeniowy z przedmiotu **Bazy Danych 4sem/ITE/WIMIIP/AGH**. Stworzony w MySQL, JavaScript, Express oraz Svelte. _(Jakość kodu jest dosyć mierna, gdyż dopiero uczę się jsa oraz svelta)._ Jego celem było stworzenie prostej bazy danych symulującej system do obsługi giełdy kryptowalut.

Aby uruchomić należy:

- utworzyć bazę danych crypto-echange na localhoscie stosując plik database/database.sql (w tym celu wykorzystywałem XAMPPa)
- uruchomić serwer (backend) `node server/server.js`
- w drugim terminalu przejsc do katalogu frontend a następnie uruchomić polecenie `npm run dev`
- dostępne podstrony: /, /register, /dashboard, /assets, /deposit, /withdraw oraz /admin.
