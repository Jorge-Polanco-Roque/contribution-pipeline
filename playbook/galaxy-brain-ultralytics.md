# Galaxy Brain — plantillas de respuesta para Q&A de Ultralytics

> Objetivo: responder Discussions **categoría Q&A** de `ultralytics/ultralytics` con
> respuestas que el autor marque como *answer* (2 aceptadas = tier 1 de Galaxy Brain).
> Estas son plantillas; adaptar al caso concreto antes de publicar. Tono: directo,
> útil, con código que corre. API del paquete `ultralytics` (YOLO11/YOLOv8).
>
> Regla de oro: responder **solo** lo que dominas y con precisión — una respuesta
> aceptada vale, una incorrecta quema. Verificar la versión del usuario (`yolo version`).

---

## 1. "How do I train on my custom dataset?" / errores de `data.yaml`

The most common cause is the dataset layout or the `data.yaml`. Ultralytics expects
`labels/` as a sibling of `images/`, with one `.txt` per image (same stem) in
normalized `class cx cy w h` format:

```
dataset/
  images/train/img1.jpg
  images/val/img2.jpg
  labels/train/img1.txt   # e.g. "0 0.51 0.34 0.22 0.18"
  labels/val/img2.txt
```

```yaml
# data.yaml
path: /abs/path/to/dataset   # absolute path avoids "images not found"
train: images/train
val: images/val
names:
  0: person
  1: car
```

```bash
yolo detect train data=data.yaml model=yolo11n.pt epochs=100 imgsz=640 batch=16
```

If it "trains but finds 0 labels": the `labels/` folder isn't a sibling of `images/`,
or the class index is out of range for `names`. Check `runs/detect/train/labels.jpg`
to confirm your boxes are read correctly.

---

## 2. "How do I track objects with IDs?" (ByteTrack / BoT-SORT)

Use `.track()` with `persist=True` so IDs are kept across frames:

```python
from ultralytics import YOLO

model = YOLO("yolo11n.pt")
for r in model.track(source="video.mp4", tracker="bytetrack.yaml",
                     persist=True, conf=0.3, stream=True):
    if r.boxes.id is None:
        continue
    ids   = r.boxes.id.int().tolist()
    boxes = r.boxes.xyxy.cpu().numpy()
    # ... your logic per track id
```

- `tracker=` is `bytetrack.yaml` (fast, no ReID) or `botsort.yaml` (ReID, better through
  occlusions). Copy one and tweak (`track_high_thresh`, `track_buffer`) for your video.
- `persist=True` is required when you call `track()` frame-by-frame; without it the
  tracker resets each call and IDs restart.
- IDs churn when detections drop — raise `track_buffer` and/or lower `conf` a bit.

---

## 3. "How do I export to ONNX / TensorRT / CoreML?"

```python
model = YOLO("best.pt")
model.export(format="onnx", opset=12, dynamic=True, simplify=True)  # ONNX
model.export(format="engine", half=True, device=0)                  # TensorRT (.engine)
model.export(format="coreml", nms=True)                             # CoreML (Apple)
```

Then load the exported weights the same way: `YOLO("best.onnx")`.

- `dynamic=True` allows variable batch/size; drop it if your runtime needs a fixed shape.
- TensorRT (`format="engine"`) must be built **on the same GPU/TensorRT version** you
  deploy on — an engine is not portable across GPUs.
- If ONNX inference results differ slightly, that's expected (fp accumulation); use
  `half=False` to rule out precision.

---

## 4. "CUDA out of memory" during training

Lower memory pressure in this order:

```bash
yolo detect train data=data.yaml model=yolo11s.pt imgsz=640 batch=-1
```

- `batch=-1` uses AutoBatch (targets ~60% VRAM) — good first move.
- If still OOM: set an explicit smaller `batch` (8, 4), reduce `imgsz` (640→512), or use
  a smaller model (`yolo11s`→`yolo11n`).
- `cache=disk` (not `ram`) if RAM is the issue, not VRAM.
- Close other GPU processes; check with `nvidia-smi`. AMP is on by default and already
  helps.

---

## 5. "Inference on a long video eats all my RAM"

Use `stream=True` — it returns a generator and processes frame-by-frame instead of
loading every result into a list:

```python
for r in model.predict(source="long.mp4", stream=True):
    process(r)      # r is freed each iteration
```

Without `stream=True`, `predict()` accumulates all `Results` in memory. This is the #1
cause of OOM on videos/streams.

---

## 6. "My mAP is low / it doesn't detect anything"

Checklist, most-common-first:

1. **Verify labels are read**: open `runs/detect/train/labels.jpg` and `train_batch0.jpg`
   — if boxes are wrong/absent, it's a data problem, not the model.
2. **Train long enough**: `epochs=100+` for small datasets; watch `results.png` for the
   loss/mAP curve to plateau (use `patience` for early stop).
3. **Start from pretrained** (`model=yolo11n.pt`, not `.yaml`) unless you have lots of data.
4. **Class imbalance / too few images**: aim for ≥~200 instances per class; add data or
   augmentation before touching hyperparameters.
5. **imgsz**: small objects need larger `imgsz` (e.g. 1280).

Only tune hyperparameters (`lr0`, augmentation) after the above are solid.

---

## 7. "How do I resume an interrupted training?"

```bash
yolo detect train resume model=runs/detect/train/weights/last.pt
```

```python
YOLO("runs/detect/train/weights/last.pt").train(resume=True)
```

Use `last.pt` (not `best.pt`) — resume needs the optimizer state, which only `last.pt`
carries. It continues the *same* run to the original `epochs`.

---

## 8. "How do I get boxes / classes / confidences out of the results?"

`predict()`/`track()` return `Results` objects; the tensors are on `r.boxes`:

```python
r = model.predict("img.jpg")[0]
xyxy  = r.boxes.xyxy.cpu().numpy()   # (N,4) pixel coords
conf  = r.boxes.conf.cpu().numpy()   # (N,)
cls   = r.boxes.cls.int().tolist()   # class indices
names = [model.names[c] for c in cls]
ids   = r.boxes.id                    # only set when tracking
```

For segmentation use `r.masks`, for pose `r.keypoints`, for OBB `r.obb`.

---

## 9. "How do I filter to only certain classes / set thresholds?"

Do it at inference (no retraining needed):

```python
model.predict(source="img.jpg", classes=[0, 2], conf=0.25, iou=0.7)
```

- `classes=` keeps only those class indices.
- `conf=` is the min confidence; `iou=` is the NMS IoU (lower = more aggressive box
  merging). These are inference args, not training args.

---

## 10. "How do I count objects / detect line crossings?"

Use the built-in `solutions` module instead of writing it yourself:

```python
from ultralytics import solutions

counter = solutions.ObjectCounter(
    model="yolo11n.pt",
    region=[(20, 400), (1080, 400)],   # counting line/polygon
    classes=[0],                        # count people only
)
# feed frames (e.g. from cv2.VideoCapture); counter(frame) returns the annotated frame
```

`region` as 2 points = a line (in/out crossing); as a polygon = zone counting. It wraps
tracking + counting so IDs aren't double-counted.

---

## 11. "cpu / mps / device selection" (Mac & multi-GPU)

```python
model.predict(source=..., device=0)        # first CUDA GPU
model.predict(source=..., device="cpu")    # CPU
model.predict(source=..., device="mps")    # Apple Silicon GPU
model.train(..., device=[0, 1])            # multi-GPU DDP
```

On Apple Silicon `device="mps"` works for inference and most training; if you hit an
unsupported-op error, fall back to `device="cpu"` for that step. `mps` is usually a big
speedup over CPU on M-series.

---

## Notas de uso (para no quemar reputación)
- Confirmar la **versión** del usuario y adaptar nombres de modelo (`yolo11*` vs `yolov8*`).
- Pegar **solo** el bloque relevante; añadir 1 línea que aborde su caso específico
  (número de clases, tipo de fuente, GPU) — las respuestas genéricas rara vez se marcan.
- Si no estás seguro, **no responder**: Galaxy Brain premia respuestas *aceptadas*, y una
  incorrecta daña más de lo que suma.
- Enlazar a la doc oficial relevante cuando aplique (refuerza credibilidad).
