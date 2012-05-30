/* timeCluster.c
 * 
 * Author: Shaun Brandt <sbrandt@pdx.edu>
 * 5-27-2012
 */
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <png.h>
#include <zlib.h>

typedef struct
{
	unsigned char r;
	unsigned char g;
	unsigned char b;
} Color;

Color colorList[8]; 

int tlX, tlY, blX, blY, trX, trY, brX, brY;
png_uint_32 imageWidth, imageHeight;
int bitDepth, colorType;
int dataPoints;
float widthPerTimeSlice;

unsigned char *imageData;
int *clusterData;

static png_structp pngPtr;
static png_infop infoPtr;

/* Add a color to the palette.  Only 8 colors are supported at this time. */
void createColor(int index, unsigned char r, unsigned char g, unsigned char b)
{
	colorList[index].r = r;
	colorList[index].g = g;
	colorList[index].b = b;
}

int heuristicSetExtents()
{
	int isDone = 0;
	int i,j;
	int count;
	int tlx, tly, blx, bly, trx, try, brx, bry;
	int val;
	
	i = 0;
	tlx = -1;
	tly = -1;
	blx = -1;
	bly = -1;
	trx = -1;
	try = -1;
	brx = -1;
	bry = -1;
	
	while(i < imageWidth && !isDone)
	{
		count = 0;
		for(j=0;j<imageHeight;j++)
		{
			val = getPixelDataOffset(i, j);
			if(imageData[val] == 128 && imageData[val+1] == 128 && imageData[val+2] == 128)
			{
			   count++;
			}
		}
		if(count > (int)((float)imageHeight * 0.8))
		{
			isDone = 1;
			tlx = i;
			blx = i;
		}
		i++;
		if(i >= imageWidth)
		{
			isDone = 1;
		}
	}
	
	if(!isDone)
	{
		return -1;
	}
	
	/* Now that we have a tlx, we can use it to find tly and try, */
	i = 0;
	isDone = 0;
	while (i <imageHeight && !isDone)
	{
		val = getPixelDataOffset(tlx, i);
		if(imageData[val] == 128 && imageData[val+1] == 128 && imageData[val+2] == 128)
		{
			isDone = 1;
			tly = i;
			try = i;
		}
		i++;
		if(i >= imageHeight)
		{
			isDone = 1;
		}		
	}
	
	if(!isDone)
	{
		return -1;
	}
	
	i = imageHeight - 1;
	isDone = 0;
	while (i > 0 && !isDone)
	{
		val = getPixelDataOffset(tlx, i);
		if(imageData[val] == 128 && imageData[val+1] == 128 && imageData[val+2] == 128)
		{
			isDone = 1;
			bly = i;
			bry = i;
		}
		i--;
		if(i <= 0)
		{
			isDone = 1;
		}		
	}	
	
	if(!isDone)
	{
		return -1;
	}	
	
	i = blx + 1;
	isDone = 0;
	while (i < imageWidth && !isDone)
	{
		val = getPixelDataOffset(i, bly);
		if(imageData[val] == 255 && imageData[val+1] == 255 && imageData[val+2] == 255)
		{
			isDone = 1;
			trx = i;
			brx = i;
		}
		i++;
		if(i >= imageWidth)
		{
			isDone = 1;
		}		
	}	
	
	if(!isDone)
	{
		return -1;
	}	
	
	tlX = tlx + 1;
	tlY = tly;
	blX = blx + 1;
	blY = bly - 1;
	trX = trx - 1;
	trY = try;
	brX = brx - 1;
	brY = bry - 1;
	
	printf("Extents:\n");
	printf("Top left = (%d,%d)\n", tlX, tlY);	
	printf("Top right = (%d,%d)\n", trX, trY);	
	printf("Bottom left = (%d,%d)\n", blX, blY);	
	printf("Bottom right = (%d,%d)\n", brX, brY);	
	
	widthPerTimeSlice = (float)(((float)(brX - blX)) / (float)dataPoints);
	return 0;
	
}

/* Determine where the beginning and end of the colored area is.
 * Currently, this uses fixed sizes based on the output of the script that
 * generates the original image.
 */
void setExtents(int isLD)
{
	if (isLD)
	{
		tlX = 68;
		tlY = 16;
		blX = 68;
		blY = 431;
		trX = 554;
		trY = 16;
		brX = 554;
		brY = 431;
	}
	else
	{
		tlX = 76;
		tlY = 16;
		blX = 76;
		blY = 671;
		trX = 1066;
		trY = 16;
		brX = 1066;
		brY = 671;
	}
	
	widthPerTimeSlice = (float)(((float)(brX - blX)) / (float)dataPoints);
	if(isLD)
	{
		widthPerTimeSlice = widthPerTimeSlice + 1;
	}
}

/* Load the original image */
int loadPNG(char *fileName)
{
	FILE *fp;
	unsigned char sig[8];
	png_uint_32 i, rowBytes;
	
	imageData = NULL;
	
	fp = fopen(fileName, "rb");
	if(!fp)
	{
		return -1;
	}
	
	fread(sig, 1, 8, fp);
	if(!png_check_sig(sig, 8))
	{
		return -1;
	}
	
	pngPtr = png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
	if(!pngPtr)
	{
		return -1;
	}
	
	infoPtr = png_create_info_struct(pngPtr);
	if(!infoPtr)
	{
		png_destroy_read_struct(&pngPtr, NULL, NULL);
		return -1;
	}
	
	if(setjmp(pngPtr->jmpbuf))
	{
		png_destroy_read_struct(&pngPtr, &infoPtr, NULL);
		return -1;
	}
	
	png_init_io(pngPtr, fp);
	png_set_sig_bytes(pngPtr, 8);
	png_read_info(pngPtr, infoPtr);
	
	png_get_IHDR(pngPtr, infoPtr, &imageWidth, &imageHeight, &bitDepth, &colorType, NULL, NULL, NULL);
	
	png_bytep rowPointers[imageHeight];
	
	png_read_update_info(pngPtr, infoPtr);
	rowBytes = png_get_rowbytes(pngPtr, infoPtr);
	
	if((imageData = (unsigned char *)malloc(rowBytes * imageHeight)) == NULL)
	{
		png_destroy_read_struct(&pngPtr, &infoPtr, NULL);
		return -1;
	}
	
	for(i=0; i<imageHeight; i++)
	{
		rowPointers[i] = imageData + i*rowBytes;
	}
	
	png_read_image(pngPtr, rowPointers);
	
	printf("Image dimensions %d x %d, color depth = %d, type = %d\n", (int)imageWidth, (int)imageHeight, bitDepth, colorType);
	
	
	fclose(fp);
}

/* Loads output from extractClusterSegments.pl into an array */
int loadData(char *dataFile)
{
	FILE *fp;
	int count, dummy, i;
	
	fp = fopen(dataFile, "r");
	if(!fp)
	{
		return -1;
	}
	
	count = 0;
	while(!feof(fp))
	{
		fscanf(fp, "%d\n", &dummy);
		count++;
	}
	
	printf("Number of data items = %d\n", count);
	
	rewind(fp);
	clusterData = (int *)malloc(count * sizeof(int));
	if(!clusterData)
	{
		return -1;
	}
	
	for(i=0;i<count;i++)
	{
		fscanf(fp, "%d\n", &dummy);
		clusterData[i] = dummy;
	}

	dataPoints = count;
	fclose(fp);
	return 0;
}

/* Apply colors to the image. */
void colorImage(void)
{
	int offsetAtPoint;
	int colorAtPoint;
	int i, j, pt;
	
	for(i=tlX; i<=trX; i++)
	{
		offsetAtPoint = (int)((float)(i-tlX) / (float)widthPerTimeSlice);
		colorAtPoint = clusterData[offsetAtPoint];
		
		for(j=tlY; j<=blY; j++)
		{
			pt = getPixelDataOffset(i, j);
			imageData[pt] = (int)(((float)imageData[pt] * 0.5f) + ((float)colorList[colorAtPoint].r * 0.5f));
			imageData[pt+1] = (int)(((float)imageData[pt+1] * 0.5f) + ((float)colorList[colorAtPoint].g * 0.5f));
			imageData[pt+2] = (int)(((float)imageData[pt+2] * 0.5f) + ((float)colorList[colorAtPoint].b * 0.5f));
		}
	}
}

/* Given an x and y coordinate, find the appropriate offset into the image buffer. */
int getPixelDataOffset(int x, int y)
{
	int off;
	
	off = (y * 4 * imageWidth) + (x * 4);
	return off;
}

/* Write the colored PNG data to a file. */
int savePNG(char *fileName)
{
	FILE *fp;
	png_structp pngPtr = NULL;
	png_infop   infoPtr = NULL;
	png_byte ** rowPointers = NULL;
	int pixelSize = 4;
	int depth = 8;
	int i, j;
	int offset;
	
	fp = fopen(fileName, "wb");
	if(!fp)
	{
		return -1;
	}
	
	pngPtr = png_create_write_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
	if(pngPtr == NULL)
	{
		fclose(fp);
		return -1;
	}
	
	infoPtr = png_create_info_struct(pngPtr);
	if(infoPtr == NULL)
	{
		png_destroy_write_struct(&pngPtr, NULL);
	}
	
	if(setjmp(pngPtr->jmpbuf))
	{
		png_destroy_write_struct(&pngPtr, &infoPtr);
		return -1;
	}
	
	png_set_IHDR(pngPtr, infoPtr, imageWidth, imageHeight, depth, 
	             PNG_COLOR_TYPE_RGB_ALPHA, PNG_INTERLACE_NONE,
	             PNG_COMPRESSION_TYPE_DEFAULT, PNG_FILTER_TYPE_DEFAULT);
	             
	rowPointers = png_malloc(pngPtr, imageHeight * sizeof(png_byte *));
	for(i=0; i<imageHeight; i++)
	{
		png_byte *row = png_malloc(pngPtr, sizeof(png_byte) * imageWidth * pixelSize);
		rowPointers[i] = row;
		for(j=0; j<imageWidth; j++)
		{
			offset = getPixelDataOffset(j, i);
			*row++ = (png_byte)imageData[offset];
			*row++ = (png_byte)imageData[offset+1];
			*row++ = (png_byte)imageData[offset+2];
			*row++ = (png_byte)imageData[offset+3];
		}
	}
	
	png_init_io(pngPtr, fp);
	png_set_rows(pngPtr, infoPtr, rowPointers);
	png_write_png(pngPtr, infoPtr, PNG_TRANSFORM_IDENTITY, NULL);
	
	for(i = 0; i< imageHeight; i++)
	{
		png_free(pngPtr, rowPointers[i]);
	}
	png_free(pngPtr, rowPointers);
	
	fclose(fp);
	
	return 0;
}

int main(int argc, char *argv[])
{
	if(argc != 5)
	{
		printf("Usage: timeCluster <in image> <out image> <data> <isLD>\n");
		exit(1);
	}
	
	/* Add colors to the palette */
	createColor(0, 176, 102, 179);
	createColor(1, 219, 189, 124);
	createColor(2, 59, 59, 157);	
	createColor(3, 51,143, 51);

	printf("Loading PNG image\n");
	if(loadPNG(argv[1]) != 0)
        {
		printf("Couldn't load image!\n");
		exit(1);  
	}
	
	printf("Loading cluster data\n");
	if(loadData(argv[3]) != 0)
	{
		printf("Couldn't open cluster data!\n");
		exit(1);
	}


	if(heuristicSetExtents() == -1)
	{
		printf("Couldn't find extents automatically - trying alternate method\n");
		setExtents(atoi(argv[4]));
	}
	
	printf("Applying colors to image\n");
	colorImage();
	
	printf("Saving new PNG image\n");
	if(savePNG(argv[2]) != 0)
	{
		printf("Couldn't save PNG image!\n");
		exit(1);
	}
	
	if(imageData != NULL)
	{
		free(imageData);
	}
	if(clusterData != NULL)
	{
		free(clusterData);
	}
	
	return 0;
}
