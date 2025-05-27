# [octdata4python](https://github.com/kaygdev/octdata4python) with wheels 🛞
## Step 1: Build wheel
```bash
   python -m build
   ```
### Step 2: Create a manylinux wheel with shared libs
```bash
   python -m auditwheel repair dist/octdata4python-*-cp39-*.whl --plat manylinux_2_39_x86_64
```
