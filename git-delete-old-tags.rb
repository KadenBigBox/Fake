# WARNING: This script is SUPER distructive ~ DO NOT RUN THIS UNLESS YOU KNOW WHAT YOU ARE DOING
# deletes all tags older than the given cut off date

# CUT_OFF_DATE needs to be of YYYY-MM-DD format
CUT_OFF_DATE = "2022-10-16"

def get_old_tags(cut_off_date)  
  `git log --tags --simplify-by-decoration --pretty="format:%ai %d"`
  .split("\n")
  .each_with_object([]) do |line, old_tags|
    if line.include?("tag: ")
      date = line[0..9]
      tags = line[28..-2].gsub(",", "").concat(" ").scan(/tag: (.*?) /).flatten
      old_tags.concat(tags) if date < cut_off_date
    end
  end
end

# fetch all tags from the remote
`git fetch`

# delete all tags on the remote that were created before the CUT_OFF_DATE
get_old_tags(CUT_OFF_DATE).each_slice(100) do |batch|
  system("git", "push", "--delete", "origin", *batch)
end

# delete all local tags that are no longer present on the remote
`git fetch --prune origin +refs/tags/*:refs/tags/*`