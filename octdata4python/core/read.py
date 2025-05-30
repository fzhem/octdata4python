from pathlib import Path
from typing import Literal
from .octdata4python import readFileOpt

def read_file(
    path: str | Path,
    fill_empty_pixel_white: bool = True,
    register_bscans: bool = True,
    rotate_slo: bool = False,
    hold_raw_data: bool = False,
    load_ref_files: bool = True,
    read_bscans: bool = True,
    read_bscan_num: int = -1,
    e2e_gray_transform: Literal["nativ", "u16", "vol", "xml"] = "xml",
    xor_test: list | None = None,
) -> None:
    """
    Reads an OCT (Optical Coherence Tomography) data file using `octdata4python.readFileOpt`.

    Parameters
    ----------
    path : str or Path
        Path to the OCT data file.

    fill_empty_pixel_white : bool, optional
        Whether to fill empty pixels with white (True by default).

    register_bscans : bool, optional
        ??? (True by default).

    rotate_slo : bool, optional
        Whether to rotate SLO image. Applies **only** when reading .e2e or .sdb formats (False by default).

    hold_raw_data : bool, optional
        ??? (False by default).

    load_ref_files : bool, optional
        Param unused by backend lib (True by default).

    read_bscans : bool, optional
        Whether to read B-scan data (True by default).

    read_bscan_num : int, optional
        Index of a specific B-scan to read. Applies **only** when reading dicoms (default is -1).

    e2e_gray_transform : {"nativ", "u16", "vol", "xml"}, optional
        Method used to perform grayscale transformation for .e2e and .sdb formats. Default is "xml".

    xor_test : list, optional
        Optional list of XOR values for test or debug purposes. If None, an empty list is used.
    """
    if not xor_test:
        xor_test = []
    return readFileOpt(
        str(Path(path)),
        {
            "fillEmptyPixelWhite": fill_empty_pixel_white,
            "registerBScanns": register_bscans,
            "rotateSlo": rotate_slo,
            "holdRawData": hold_raw_data,
            "loadRefFiles": load_ref_files,
            "readBScans": read_bscans,
            "readBScanNum": read_bscan_num,
            "e2eGrayTransform": e2e_gray_transform,
            "xor_test": xor_test,
        },
    )
