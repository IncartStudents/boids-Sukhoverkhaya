[![Open in Visual Studio Code](https://classroom.github.com/assets/open-in-vscode-c66648af7eb3fe8bc4f294546bfd86ef473780cde1dea487d3c4ff354943c9ae.svg)](https://classroom.github.com/online_ide?assignment_repo_id=8078223&assignment_repo_type=AssignmentRepo)
# Boids

Материалы:
- https://en.wikipedia.org/wiki/Boids
- условия задачи: http://www.red3d.com/cwr/boids/
- пример выполнения: https://eater.net/boids

Задачи:
1. Описать предметную область (домен):
    - выделить объекты, их свойства и функции
    - дать определения объектам через другие объекты
2. Описать шаги выполнения программы
    - основные этапы вычислений
    - функции - что делаем внутри этапов
3. Описать ход решения в виде цепочки промежуточных реализаций (программа 1, программа 2, …)
4. Реализовать решение по описанию п. 1-3

Пункты 1 - 3 вставлять текстом под этой чертой:

--------------------
1. Описание предметной области:
    - игровое поле
    - объекты ("птички")
    - вектор скорости (для каждого объекта)
    - вектор ускорения (для каждого объекта)
    - область видимости (каждого объекта)
    - время (количество итераций (частота смены кадров))
2. Шаги выполнения программы:
    1. Создание игрового поля.
    2. Создание исходных параметров птичек: количество, начальное положение, направление векторов.
    3. Запуск перебора кадров (итераций).
        4. Перебор каждой птички.
            5. Проверка положения птички для обеспечения отскакивания от границ игрового поля и коррекция траектории.
            6. Проверка положения птички на соответсвие трём условиям и коррекция траектории.
        7. Завершение перебора птичек.
        8. Перерасчет положений птичек.
        9. Рисование птичек.
    4. Завершение перебора кадров.
    5. Копмилляция и создание гифки.
3. Цепочка промежуточных реализаций:
    - программа 1: поле с n птичек, отскакивающих от границ поля.
    - программа 2: функция проверки выполненения первого условия и коррекции положения птички.
    - программа 3: функция проверки выполненения второго условия и коррекции положения птички.
    - программа 4: функция проверки выполненения третьего условия и коррекции положения птички.