function cifti = cifti_create_ptseries_from_template(ciftitemplate, data, start, step, unit, dimension)
    %function cifti = cifti_create_ptseries_from_template(ciftitemplate, data, start, step, unit, dimension)
    %   Create a ptseries cifti object using the parcels info from an existing cifti object
    %
    %   The start, step, and unit arguments are optional and default to
    %   start = 0, step = 1, unit = 'SECOND'.
    %   The dimension argument is optional except when the template is
    %   pconn or another type of cifti with more than one parcels dimension,
    %   and is used to select which dimension to copy the parcels mapping from.
    if nargin < 3
        start = 0;
    end
    if nargin < 4
        step = 1;
    end
    if nargin < 5
        unit = 'SECOND';
    end
    if nargin < 6
        dimension = [];
        for i = 1:length(ciftitemplate.diminfo)
            if strcmp(ciftitemplate.diminfo{i}.type, 'parcels')
                dimension = [dimension i]; %#ok<AGROW>
            end
        end
        if isempty(dimension)
            error('template cifti has no parcels dimension');
        end
        if ~isscalar(dimension)
            error('template cifti has more than one parcels dimension, you must specify the dimension to use');
        end
    end
    if ~strcmp(ciftitemplate.diminfo{dimension}.type, 'parcels')
        error('selected dimension of template cifti file is not parcels type');
    end
    if size(data, 1) ~= ciftitemplate.diminfo{dimension}.length
        if size(data, 2) == ciftitemplate.diminfo{dimension}.length
            warning('input data is transposed, this could cause an undetected error when run on different data'); %accept transposed, but warn
            cifti.cdata = data';
        else
            error('input data does not have a dimension length matching the parcels diminfo');
        end
    else
        cifti.cdata = data;
    end
    cifti.metadata = ciftitemplate.metadata;
    cifti.diminfo = {ciftitemplate.diminfo{dimension} cifti_diminfo_make_series(size(cifti.cdata, 2), start, step, unit)};
end