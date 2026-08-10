# difftastic

**Категория:** см. [оглавление](../index.md) · **ID в каталоге:** `difftastic`

## Что это

Структурный diff для исходников: сравнивает код по синтаксису, а не только построчно. Команда: `difft`.

## Зачем нужен

Понятнее смотреть изменения в коде, чем с обычным `diff`/`git diff` — особенно при перестановках и рефакторинге.

## Примеры

```bash
difft old.rs new.rs
GIT_EXTERNAL_DIFF=difft git diff
git config --global diff.external difft
```

## Установка через CLI Toolbox

```bash
./install.sh --only difftastic
```

Определение: [`catalog/tools/difftastic.yaml`](../../catalog/tools/difftastic.yaml).

## Ссылки

- [difftastic.wilfred.me.uk](https://difftastic.wilfred.me.uk/)
- [GitHub](https://github.com/Wilfred/difftastic)
