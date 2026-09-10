import json

data = """
{
    "id": 11,
    "author": 49,
    "author_name": "Nissan chick",
    "category": 1,
    "category_name": "Live Streams",
    "content_type": "video",
    "status": "published",
    "title": "ghdg",
    "description": "dghdg",
    "thumbnail": null,
    "video": "http://savannah-courage-bigger-poems.trycloudflare.com/media/videos/REC5577701088088690722.mp4",
    "author_profile": "http://savannah-courage-bigger-poems.trycloudflare.com/media/profile_pictures/image_picker_BC461809-4640-4345-8BF3-46D6DBAD1760-51656-00000049779CE7CF.jpg",
    "views_count": 1,
    "favorite_count": 0,
    "share_count": 3,
    "created_at": "2026-07-27T04:01:00.355781Z",
    "created_at_ago_time": "23 hours, 40 minutes ago",
    "content_like_count": 1,
    "content_dislike_count": 0,
    "content_comment_count": 5,
    "comments": [
        {
            "id": 5,
            "commenter": 49,
            "commenter_name": "Nissan chick",
            "commenter_username": "nishan6699",
            "commenter_profile": "http://savannah-courage-bigger-poems.trycloudflare.com/media/profile_pictures/image_picker_BC461809-4640-4345-8BF3-46D6DBAD1760-51656-00000049779CE7CF.jpg",
            "comment": "hello",
            "created_at": "2026-07-28T03:17:59.906097Z",
            "created_at_time_ago": "1 hour, 22 minutes ago",
            "comment_likes_count": 0,
            "comment_dislikes_count": 0,
            "replies": [
                {
                    "id": 1,
                    "comment_id": 5,
                    "commenter": 49,
                    "commenter_name": "Nissan chick",
                    "commenter_username": "nishan6699",
                    "commenter_profile": "http://savannah-courage-bigger-poems.trycloudflare.com/media/profile_pictures/image_picker_BC461809-4640-4345-8BF3-46D6DBAD1760-51656-00000049779CE7CF.jpg",
                    "comment": "reply 1",
                    "created_at": "2026-07-28T04:22:59.906097Z",
                    "created_at_time_ago": "10 minutes ago"
                }
            ]
        }
    ]
}
"""
try:
    print(json.loads(data)["comments"][0]["replies"])
except Exception as e:
    pass
