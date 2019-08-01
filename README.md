# Detectron
Detectron is the object detection collection from Facebook Research. Original repo is [here](https://github.com/facebookresearch/Detectron). Since facebook research version could encounter some errors during parsing yaml file, I have fixed this issue by fixing pyyamml version in requirement.txt. [Related Issue](https://github.com/facebookresearch/Detectron/issues/840) In my repository I use [my forked version](https://github.com/TeeboneTing/Detectron) of Detectron and works well now.

# How to use
## Build image by yourself 
* Clone this repository with submodule: `git clone --recursive git@github.com:TeeboneTing/Detectron_k8s.git`
* Build image: `make build`
* If you would like to push to your dockerhub repository, please change your username in Makefile line 3 and `make push_dockerhub`
## Acutally you can run docker image without build by yourself
* Run image by `docker run -ti teeboneding/detectron bash`
* Execute example inference command inside container from [GETTING_STARTED](https://github.com/TeeboneTing/Detectron/blob/master/GETTING_STARTED.md):
``` bash
python tools/infer_simple.py \
    --cfg configs/12_2017_baselines/e2e_mask_rcnn_R-101-FPN_2x.yaml \
    --output-dir /tmp/detectron-visualizations \
    --image-ext jpg \
    --wts https://dl.fbaipublicfiles.com/detectron/35861858/12_2017_baselines/e2e_mask_rcnn_R-101-FPN_2x.yaml.02_32_51.SgT4y1cO/output/train/coco_2014_train:coco_2014_valminusminival/generalized_rcnn/model_final.pkl \
    demo
```
## Train RetinaNet
### Prepare Dataset
* According to [dataset readme](https://github.com/TeeboneTing/Detectron/blob/master/detectron/datasets/data/README.md), create your own dataset with COCO format and put into path `detectron/datasets/data`. 
* To add your dataset into Detectron catalog, please refer to [dataset_catalog.py](https://github.com/TeeboneTing/Detectron/blob/master/detectron/datasets/dataset_catalog.py). Add your dataset information in `_DATASETS` dict.
### Start Training
1. Make a soft link for dataset to correct place
2. Setup RetinaNet config files and model output path
3. Inside the container with commands below:
``` bash
ln -s /tmp/detectron/coco /detectron/detectron/datasets/data/coco ; \
python tools/train_net.py --cfg new_configs/getting_started/retinanet_X-101-32x8d-FPN_1x.yaml OUTPUT_DIR /tmp/detectron/detectron/model
```
### Current Training Parameters
ref: [retinanet_X-101-32x8d-FPN_1x.yaml](https://github.com/TeeboneTing/Detectron_k8s/blob/master/configs/getting_started/retinanet_X-101-32x8d-FPN_1x.yaml)
```
MODEL:
  TYPE: retinanet
  CONV_BODY: FPN.add_fpn_ResNet101_conv5_body
  NUM_CLASSES: 2 # Class number should be your dataset class number + 1 (for background class)
NUM_GPUS: 1 # Change your GPU number here
SOLVER:
  WEIGHT_DECAY: 0.0001
  LR_POLICY: steps_with_decay
  BASE_LR: 0.001 # Original LR is 0.01 which is too high for a pretrained model
  GAMMA: 0.1
  MAX_ITER: 90000
  STEPS: [0, 60000, 80000]
FPN:
  FPN_ON: True
  MULTILEVEL_RPN: True
  RPN_MAX_LEVEL: 7
  RPN_MIN_LEVEL: 3
  COARSEST_STRIDE: 128
  EXTRA_CONV_LEVELS: True
RESNETS:
  STRIDE_1X1: False  # default True for MSRA; False for C2 or Torch models
  TRANS_FUNC: bottleneck_transformation
  NUM_GROUPS: 32
  WIDTH_PER_GROUP: 8
RETINANET:
  RETINANET_ON: True
  NUM_CONVS: 4
  ASPECT_RATIOS: (1.0, 2.0, 0.5)
  SCALES_PER_OCTAVE: 3
  ANCHOR_SCALE: 4
  LOSS_GAMMA: 2.0
  LOSS_ALPHA: 0.25
TRAIN:
  WEIGHTS: /tmp/detectron/detectron/X-101-32x8d.pkl # ImageNet pretrained model. Download link: https://dl.fbaipublicfiles.com/detectron/ImageNetPretrained/20171220/X-101-32x8d.pkl
  DATASETS: ('ubitus_anime2019',) # Replace your training/validation dataset name here
  #SCALES: (500,)
  #MAX_SIZE: 833
  #IMS_PER_BATCH: 4
  #BATCH_SIZE_PER_IM: 128
  RPN_PRE_NMS_TOP_N: 2000  # Per FPN level
  RPN_STRADDLE_THRESH: -1  # default 0
#TEST:
#  DATASETS: ('coco_2014_minival',)
#  SCALE: 800
#  MAX_SIZE: 1333
#  NMS: 0.5
#  RPN_PRE_NMS_TOP_N: 10000  # Per FPN level
#  RPN_POST_NMS_TOP_N: 2000
OUTPUT_DIR: .
DATA_LOADER:
  MINIBATCH_QUEUE_SIZE: 64
```

# Some example output images:

![korea fish 1](example/1.jpg)

![korea fish 2](example/2.jpg)

![korea fish 3](example/3.jpg)

![korea fish 4](example/4.jpg)

# Update
* 20190801 Add training process
* 20190725 First update

# TODOs
