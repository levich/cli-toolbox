# pip

**Категория:** см. [оглавление](../index.md) · **ID в каталоге:** `pip`

## Что это

Стандартный установщик пакетов для Python (`pip` / `pip3`).

## Зачем нужен

Установка библиотек из PyPI в системное или виртуальное окружение. Для новых проектов часто удобнее [uv](uv.md), но pip остаётся универсальным и ожидаемым инструментом.

Зависит от [Python](python.md) (`needs: [python]`).

## Примеры

```bash
pip3 --version
pip3 install requests
python3 -m pip install --user httpie
pip3 list
```

## Установка через CLI Toolbox

```bash
./install.sh --only python,pip
./install.sh --update --only pip
```

На macOS (Homebrew) pip приходит вместе с пакетом `python`. На Linux ставятся `python3-pip` / `python-pip` / `py3-pip` в зависимости от дистрибутива.

Определение пакета: [`catalog/tools/pip.yaml`](../../catalog/tools/pip.yaml).

## Ссылки

- [pip.pypa.io](https://pip.pypa.io/)
