# CLI Toolbox

Расширяемый набор CLI/desktop-утилит с документацией и кроссплатформенным установщиком.

Поддерживаются **macOS**, **Linux** (Ubuntu, Debian, Alpine, Arch, ALT, Fedora и др.) и **Windows через WSL**.

## Быстрый старт

```bash
./install.sh --list
./install.sh --installed
./install.sh --installed-ids
./install.sh --remove --only micro -y
./install.sh --profile cli,dev
./install.sh --profile admin
./install.sh --profile shell --save-tips
./install.sh --interactive
./install.sh --update --profile cli
```

После установки выводятся рекомендации по настройке и ссылки на документацию; `--save-tips` сохраняет их в файл.

Подробности: [docs/install.md](docs/install.md).

## Документация утилит

Описание каждой утилиты: [docs/index.md](docs/index.md).

Краткий перечень: [list.md](list.md).

## Структура

```text
install.sh           # точка входа
catalog/tools/       # один YAML на инструмент (расширяемый каталог)
catalog/profiles.yaml
lib/                 # detect, package managers, selection
lib/custom/          # особые установщики
docs/                # документация
```

## Добавить инструмент

1. `catalog/tools/<id>.yaml`
2. при необходимости `lib/custom/<id>.sh`
3. профиль в `catalog/profiles.yaml`
4. страница `docs/tools/<id>.md`
