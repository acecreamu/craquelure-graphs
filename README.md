![image preview](https://github.com/acecreamu/craquelure-graphs/blob/master/img_preview.jpg)

Supporting code to the publication [TBA](https://arxiv.org)

# Option 1. Extraction and characterization of craquelure patterns from an image

Taking a skeletonized binary image as an input, given algorithm extracts non-directed graph from a cracks pattern, classifies nodes by topology onto X, Y, and O types, fits edges with polynomial, and exports comprehensive characteristic of a craquelure pattern. The latter can be used for forgery detection, origin examination, aging monitoring, and damage identification.

### Technical details

We thank [alchemyst](https://github.com/alchemyst/ternplot) and [phi-max](https://github.com/phi-max/skel2graph3d-matlab) for their algorithms which we modify and apply in our code. All the rights to original implementations belong to the authors.

The code is written under MatLab R2017b, other versions haven't be tested. Unlikely anything but the Image Processing Toolbox is required. If you find any surprising dependency - please notify us.

Binarization of the crack images is very tricky and ungreatful process so we leave it for a user's responsibility. (Although we provide a helper code `prepare_bw.m` which was used in our experiments (parameters are in filenames of the images)).
</br>
#### Output:
![image preview](https://github.com/acecreamu/craquelure-graphs/blob/master/img_graph.jpg)
![image preview](https://github.com/acecreamu/craquelure-graphs/blob/master/img_stats.jpg)

</br></br>

# Option 2. Extraction of graph features using GNN

The algorithm takes a banch of labeled graphs, uses them to train GNN, and then extracts a vector hidden features from the GNN's layers for each graph.

### Technical details
The implemention is based on [this algorithm by Xu *et al.*](https://github.com/weihua916/powerful-gnns). </br>
Requirements: 
```
PyTorch
tqdm
numpy
networkx
scipy
```
### Running the code
As simple as
```
python main.py --dataset CRACKS --lr 0.001 --epochs 10 --fold_idx 0
```
The output is a .mat file `graph-features.mat` containing one variable of the size `[N_graphs x N_features]`.
</br>
### Custom dataset
If you want to use custom dataset run `createTXT.m` and move the output to `/dataset/CRACKS/`. </br>

The structure of the .txt is following:
- each graph is a block
- first line of a block consist of *%number of nodes%* *%class label%*
- each following line describes single node in a way: *%node label%* *%number of connected nodes%* *%connected node #1%* *%connected node #2%* *%connected node #3%*...
- row number correspond to the node's index, starting from 0
- test/train partition is defined by cross-validation and doesn't appear in .txt

For example:
```
10 7
0 3 1 2 9
0 3 0 2 9
0 4 0 1 3 9
0 3 2 4 5
0 3 3 5 6
0 5 3 4 6 7 8
0 4 4 5 7 8
0 3 5 6 8
0 3 5 6 7
1 3 0 1 2
```
The block corespond to graph which consist of 10 nodes and belongs to class 7. First (0) node has label 0 and has 3 neighbours; these neighbours are nodes 1, 2, and 9. The same can be applied to the next nodes.




</br>

![image preview](https://github.com/acecreamu/craquelure-graphs/blob/master/img_gnn.jpg)

</br>
*Please cite the paper if you find our algorithm useful.*
#### Good luck with your experiments.
</br>
