Dear {{ developer.name }},

This is to inform you that {{ post.posted_by }} removed the following post:

Post title: {{ post.title }}
Company: {{ post.posted_by }} ({{ post.company_url }})
% tags = post.tags.split(",").join(", ")
Tags: {{ tags }}
% if post.location
Location: {{ post.location }}
% else
Location: Not specified
% end
% if post.remote == "true"
(Work from anywhere)
% else
(On-site only)
% end
Description:
{{ post.description }}

Remember there are more jobs waiting for you at https://jobs.punchgirls.com !

Kind regards,

Cecilia & Mayn,
Punchgirls

https://twitter.com/punchgirls
http://www.punchgirls.com
https://github.com/punchgirls
