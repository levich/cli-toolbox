# yq

**Категория:** см. [оглавление](../index.md) · **ID в каталоге:** `yq`

## Что это

Аналог jq для YAML (и часто XML/CSV) — реализация mikefarah/yq.

## Зачем нужен

Правка Kubernetes-манифестов и CI-конфигов из CLI.

## Примеры

```bash
yq '.metadata.name' deploy.yaml
yq -i '.replicas = 3' deploy.yaml
```

## Установка через CLI Toolbox

```bash
./install.sh --only yq
./install.sh --update --only yq
```

Определение пакета: [`catalog/tools/yq.yaml`](../../catalog/tools/yq.yaml).

## Ссылки

- [GitHub](https://github.com/mikefarah/yq)
