# Simple Haxe/OpenFL Game

Простая аркадная игра на Haxe и OpenFL:

- Управляй красным квадратом стрелками
- Собирай жёлтые кружки
- Стреляй (пробел) при кратном 5 счёте
- Уничтожай врагов
- Избегай столкновений — иначе GAME OVER
- Есть кнопка перезапуска

---

## 🔧 Установка

1. Установи [Haxe](https://haxe.org/download/)
2. Установи OpenFL:

   ```bash
   haxelib install openfl
   haxelib install lime
   haxelib run openfl setup
   ```

   • ← ↑ ↓ → — движение
   • SPACE — выстрел (если score % 5 == 0)
   • RESTART — перезапуск после поражения
