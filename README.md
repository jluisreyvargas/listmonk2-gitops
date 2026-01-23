# repo-gitops — Manifiestos (Kustomize) gestionados por Argo CD

Este repo es la **fuente de verdad** declarativa.

- Namespace `listmonk`
- PostgreSQL (`StatefulSet` + PVC)
- Listmonk con **Argo Rollouts (Blue/Green)**
- **SealedSecret** (DB + admin) — *sin secretos en Git*

---

## 1) Cambia la imagen (GHCR)

Edita `apps/listmonk/overlays/local/kustomization.yaml`:

- `newName: ghcr.io/TU_ORG/listmonk2`
- `newTag: sha-...` (sale de la GitHub Action del repo-app)

---

## 2) Genera el SealedSecret

Instala `kubeseal` en tu máquina (cliente) y asegúrate de que `kubectl` apunta al cluster.

Exporta variables (NO las comitees):

```bash
export DB_USER=listmonk
export DB_PASSWORD='...'
export ADMIN_USER=admin
export ADMIN_PASSWORD='...'
```

Genera el SealedSecret:

```bash
./scripts/generate-sealedsecret.sh
```

Haz commit del fichero resultante (está cifrado con la clave pública del cluster).

---

## 3) Verificar despliegue

En Argo CD:
- App `listmonk2` en *Synced/Healthy*

En CLI:

```bash
kubectl -n listmonk get rollout,svc,ingress,pods
kubectl argo rollouts -n listmonk get rollout listmonk
```

### Promover versión (Blue/Green)

```bash
kubectl argo rollouts -n listmonk promote listmonk
```

### Rollback

```bash
kubectl argo rollouts -n listmonk undo listmonk
```
