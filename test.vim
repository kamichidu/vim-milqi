let [package, class, field, method]= unite#sources#javaimport#define()

command! MilqiPackage call milqi#candidate_first(milqi#bridge#unite#new(package))
command! MilqiClass call milqi#candidate_first(milqi#bridge#unite#new(class))
command! MilqiField call milqi#candidate_first(milqi#bridge#unite#new(field))
command! MilqiMethod call milqi#candidate_first(milqi#bridge#unite#new(method))

call milqi#candidate_first(milqi#bridge#unite#new(package))
