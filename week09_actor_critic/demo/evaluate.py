"""Evaluate one saved policy on the 20 held-out test starts, without rendering."""
import argparse
import json
from pathlib import Path
import torch
from algorithm import evaluate
from train import load_checkpoint

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--checkpoint',type=Path,default=Path(__file__).with_name('classroom')/'trained.pt')
    p.add_argument('--output',type=Path)
    a=p.parse_args();torch.set_num_threads(1)
    try:
        model,metadata=load_checkpoint(a.checkpoint)
        result=evaluate(model)
        print(json.dumps({k:v for k,v in result.items() if k!='episodes'},indent=2))
        if a.output:
            a.output.parent.mkdir(parents=True,exist_ok=True)
            a.output.write_text(json.dumps(dict(checkpoint=str(a.checkpoint),steps=metadata['steps'],results=result),indent=2)+'\n')
    except (ValueError,OSError) as e:p.exit(1,str(e)+'\n')
