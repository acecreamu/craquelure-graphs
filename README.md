![image preview](https://github.com/acecreamu/craquelure-graphs/blob/master/img_preview.jpg)

# Extraction and characterization of craquelure patterns from images
Supporting code to the publication [TBA](https://arxiv.org)

Taking a skeletonized binary image as an input, given algorithm extracts undirected graph from cracks pattern, classifies nodes by topology onto X, Y, and O types, fits edges with polynomial, and exports comprehensive characteristic of a craquelure pattern. The latter can be used for forgery detection, origin examination, aging monitoring, and damage identification.

*Disclaimer*: The code is on the stage of development!

### Technical details

We thank [alchemyst](https://github.com/alchemyst/ternplot) and [phi-max](https://github.com/phi-max/skel2graph3d-matlab) for their algorithms which we modify and apply in our code. All the rights to original implementations belong to authors.

The code is written under MatLab R2017b, other versions haven't be tested. Unlikely anything but the Image Processing Toolbox is required. If you find any surprising dependency - please notify us.

Binarization of the crack images is very tricky and ungreatful process so we leave it for a user's responsibility. (Although we provide a helper code `prepare_bw.m` which was used in our experiments (parameters are in filenames of the images)).

</br>

</br>

*Please cite the paper if you find our algorithm useful or you just have a strong desire to cite something.*
#### Good luck in your experiments.
</br>

![image preview](https://github.com/acecreamu/craquelure-graphs/blob/master/img_graph.jpg)
![image preview](https://github.com/acecreamu/craquelure-graphs/blob/master/img_stats.jpg)
