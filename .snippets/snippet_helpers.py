from pathlib import Path
import os

def gen_ifndef_uid(p):
    p = Path(p).absolute()
    relpath = p.relative_to(os.environ['MYDIR'])
    return '_FLEXFLOW_' + str(relpath).upper().replace('/', '_').replace('.', '_')

def get_lib_root(p: Path):
    p = Path(p).absolute()
    for par in p.parents:
        if not par.relative_to(os.environ['MYDIR']):
            raise RuntimeError('Could not find lib root')
        if (par / 'CMakeLists.txt').exists():
            return par

def with_suffixes(p, suffs):
    name = p.name
    while '.' in name:
        name = name[:name.rfind('.')]
    return p.with_name(name + suffs)

def get_include_path(p: Path):
    p = Path(p).absolute()
    lib_root = get_lib_root(p)
    relpath = p.relative_to(lib_root / 'src')
    include_dir = lib_root / 'include'
    src_dir = lib_root / 'src'
    public_include = include_dir / with_suffixes(relpath, '.h')
    private_include = src_dir / with_suffixes(relpath, '.h')
    if public_include.exists():
        return str(public_include.relative_to(include_dir))
    if private_include.exists():
        return str(private_include.relative_to(src_dir))
