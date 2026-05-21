# Git workflow

Bu repo uchun asosiy ish tartibi:

- `dev` - default branch. Kundalik development shu branch atrofida yuritiladi.
- `prod` - productionga tayyor oxirgi holat. `dev`dagi tekshirilgan o'zgarishlar `prod`ga merge qilinadi.
- `main` - tarixiy/stabil branch sifatida saqlanadi. Yangi tasklar uchun default branch emas.
- `nomonjon` - shaxsiy yoki vaqtinchalik ish branchi sifatida ishlatilishi mumkin, lekin yangi tasklar issue asosida alohida branchda qilinadi.

## Task ishlash tartibi

1. GitHub'da task uchun issue ochiladi.
2. `dev` branchdan yangi branch yaratiladi:

```bash
git switch dev
git pull --ff-only origin dev
git switch -c issue-<issue-raqam>-qisqa-nom
```

3. O'zgarishlar kichik, tushunarli commitlar bilan commit qilinadi.
4. Branch remote'ga push qilinadi:

```bash
git push -u origin issue-<issue-raqam>-qisqa-nom
```

5. Issue'ni yopish uchun `dev` branchga pull request ochiladi.
6. PR tekshiriladi, kerak bo'lsa review commentlar tuzatiladi.
7. PR `dev`ga merge qilingandan keyin issue yopiladi.

## Productionga chiqarish

`dev`dagi tekshirilgan kod `prod`ga PR yoki merge orqali olib o'tiladi:

```bash
git switch prod
git pull --ff-only origin prod
git merge --ff-only origin/dev
git push origin prod
```

Agar fast-forward bo'lmasa, GitHub'da `dev -> prod` pull request ochib, konfliktlarni PR ichida hal qilish tavsiya qilinadi.

## Branch nomlash

- `issue-12-login-fix`
- `feature/12-consumer-filter`
- `fix/18-release-signing`
- `chore/21-git-workflow`

Muhimi: branch nomida issue raqami bo'lishi kerak.

## Commit va PR qoidalari

- Commit xabari aniq bo'lsin: `fix(android): release signing fallback`.
- PR description ichida issue raqami yozilsin: `Closes #12`.
- PR faqat bitta task doirasidagi o'zgarishlarni olib kirsin.
- Lokal build/test imkon qadar PRdan oldin tekshirilsin.
