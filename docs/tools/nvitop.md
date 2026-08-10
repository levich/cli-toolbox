# nvitop

**Категория:** см. [оглавление](../index.md) · **ID в каталоге:** `nvitop`

## Что это

Интерактивный монитор NVIDIA GPU на Python с богатым UI и фильтрацией процессов.

## Зачем нужен

Мониторинг CUDA/GPU на рабочих станциях и серверах с NVIDIA; удобнее «голого» nvidia-smi для повседневного наблюдения.

## Примеры

```bash
nvitop
nvitop -m
```

## Установка через CLI Toolbox

```bash
./install.sh --only python,pip,nvitop
```

Ставится через `uv tool` / `pipx` / `pip --user`. Определение: [`catalog/tools/nvitop.yaml`](../../catalog/tools/nvitop.yaml).

## Ссылки

- [GitHub](https://github.com/XuehaiPan/nvitop)
