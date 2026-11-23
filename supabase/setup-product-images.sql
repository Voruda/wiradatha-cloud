ALTER TABLE public.products
    ADD COLUMN IF NOT EXISTS image_url text;

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'product-images',
    'product-images',
    true,
    1048576,
    ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']
)
ON CONFLICT (id) DO UPDATE
SET public = EXCLUDED.public,
    file_size_limit = EXCLUDED.file_size_limit,
    allowed_mime_types = EXCLUDED.allowed_mime_types;

DROP POLICY IF EXISTS "Product image members can upload" ON storage.objects;
CREATE POLICY "Product image members can upload"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'product-images'
    AND EXISTS (
        SELECT 1
        FROM public.products AS product
        WHERE product.business_id::text = (storage.foldername(name))[1]
          AND product.id::text = (storage.foldername(name))[2]
    )
);

DROP POLICY IF EXISTS "Product image members can update" ON storage.objects;
CREATE POLICY "Product image members can update"
ON storage.objects
FOR UPDATE
TO authenticated
USING (
    bucket_id = 'product-images'
    AND EXISTS (
        SELECT 1
        FROM public.products AS product
        WHERE product.business_id::text = (storage.foldername(name))[1]
          AND product.id::text = (storage.foldername(name))[2]
    )
)
WITH CHECK (
    bucket_id = 'product-images'
    AND EXISTS (
        SELECT 1
        FROM public.products AS product
        WHERE product.business_id::text = (storage.foldername(name))[1]
          AND product.id::text = (storage.foldername(name))[2]
    )
);

DROP POLICY IF EXISTS "Product image members can delete" ON storage.objects;
CREATE POLICY "Product image members can delete"
ON storage.objects
FOR DELETE
TO authenticated
USING (
    bucket_id = 'product-images'
    AND EXISTS (
        SELECT 1
        FROM public.products AS product
        WHERE product.business_id::text = (storage.foldername(name))[1]
          AND product.id::text = (storage.foldername(name))[2]
    )
);

NOTIFY pgrst, 'reload schema';
