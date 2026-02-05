# repo-gitops — Manifiestos (Kustomize) gestionados por Argo CD

Fuente de verdad **de la aplicación** (namespace `listmonk`). Incluye:
- PostgreSQL (StatefulSet + PVC)
- Listmonk con **Argo Rollouts (Blue/Green)**
- Ingress (active + preview)
- **SealedSecret** (DB + admin)

> **Infra/Observabilidad** (Loki/Promtail/Grafana/Prometheus/ArgoCD/Sealed‑Secrets/Mailpit) vive en **repo‑infra**.

---
## 1) Imagen (GHCR)
Edita `apps/listmonk/overlays/local/kustomization.yaml` → `images:`
- `newName: ghcr.io/<ORG>/listmonk2`
- `newTag: sha-...` o `vX.Y.Z`
> El repo **listmonk2-app** puede actualizar este tag automáticamente (job `update_gitops`).

## 2) SealedSecret (credenciales)
```bash
export DB_USER=listmonk
export DB_PASSWORD='...'
export ADMIN_USER=admin
export ADMIN_PASSWORD='...'
./scripts/generate-sealedsecret.sh
```
Sube el YAML cifrado al overlay (`sealedsecrets/`).

## 3) Verificar despliegue
```bash
kubectl -n listmonk get rollout,svc,ingress,pods
kubectl argo rollouts -n listmonk get rollout listmonk
```
### Promover (Blue/Green)
```bash
kubectl argo rollouts -n listmonk promote listmonk
```
### Rollback
```bash
kubectl argo rollouts -n listmonk undo listmonk
```

## 4) Mailpit en overlay local
Se incluye carpeta `mailpit/` con:
- `00-namespace-and-default-deny.yaml`
- `10-mailpit.yaml`
- `20-networkpolicy-allow-smtp-from-listmonk.yaml` (**selector** usa `app.kubernetes.io/name: listmonk`)
- `kustomization.yaml`

## 5) Limpieza “promtail duplicado”
Si quedaron restos en este repo (promtail/loki‑gateway): mover a `archive/` o borrar:
- `apps/logging/**promtail**`
- `sealedsecret-promtail.yaml`
- `promtail-secret-patch.yaml`

---
