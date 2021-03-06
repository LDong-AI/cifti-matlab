function cifti = cifti_dense_replace_voldata_structure(cifti, data, structure, cropped, dimension)
    %function cifti = cifti_dense_replace_voldata_structure(cifti, data, structure, cropped, dimension)
    %   Replace the data in a single cifti volume structures, taking a 4D array as input.
    %   For a single-map cifti, the input can be 3D instead.
    %
    %   The cropped argument is optional and defaults to false, expecting a volume with
    %   the full original dimensions.
    %   The dimension argument is optional except for dconn files (generally, use 2 for dconn).
    %   The cifti object must have exactly 2 dimensions.
    if length(cifti.diminfo) < 2
        error('cifti objects must have 2 or 3 dimensions');
    end
    if length(cifti.diminfo) > 2
        error('this function only operates on 2D cifti, use cifti_dense_get_surface_mapping instead');
    end
    if nargin < 4
        cropped = false;
    end
    if nargin < 5
        dimension = [];
        for i = 1:2
            if strcmp(cifti.diminfo{i}.type, 'dense')
                dimension = [dimension i]; %#ok<AGROW>
            end
        end
        if isempty(dimension)
            error('cifti object has no dense dimension');
        end
        if ~isscalar(dimension)
            error('dense by dense cifti (aka dconn) requires specifying the dimension argument');
        end
    end
    otherdim = 3 - dimension;
    otherlength = size(cifti.cdata, otherdim);
    [voxlist1, ciftilist, voldims, ~] = cifti_dense_get_vol_structure_map(cifti.diminfo{dimension}, structure, cropped);
    indlist = cifti_vox2ind(voldims, voxlist1);
    datadims = size(data);
    if length(datadims) < 4
        if otherlength ~= 1 || length(datadims) < 3
            error('data must have 4 dimensions (or 3 for a single-map cifti)');
        end
        datadims = [datadims 1];
    end
    if datadims(1:3) ~= voldims
        error('input data has the wrong volume dimensions, check the "cropped" argument');
    end
    if datadims(4) ~= otherlength
        error('input data has the wrong number of frames');
    end
    if otherlength == 1 %don't loop if we don't need to
        cifti.cdata(ciftilist) = data(indlist);
    else
        %have a dimension that goes after the ind2sub result, so loop
        for i = 1:otherlength
            tempframe = data(:, :, :, i);
            if dimension == 1
                cifti.cdata(ciftilist, i) = tempframe(indlist);
            else
                cifti.cdata(i, ciftilist) = tempframe(indlist);
            end
        end
    end
end
