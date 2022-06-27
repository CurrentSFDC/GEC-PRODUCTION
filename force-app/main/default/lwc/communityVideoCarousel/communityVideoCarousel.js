import {LightningElement} from 'lwc';
//import testVideo1 from '@salesforce/contentAssetUrl/testVideo1';
//import testVideo2 from '@salesforce/contentAssetUrl/testVideo2';
//import testImage from '@salesforce/contentAssetUrl/testImage';

const YOU_TUBE_VIDEO = "youTubeVideo";
const LOCAL_VIDEO = "localVideo";
const IMAGE = "image";

export default class CommunityVideoCarousel extends LightningElement {

    startIndex = 0;
    hasRendered = false;
    selectedMediaElement = {};
    mediaContainerWidth;
    mediaElements = [
        /*
        {
            mediaType: LOCAL_VIDEO,
            source: testVideo1
        },
        {
            mediaType: IMAGE,
            source: testImage
        },
        {
            mediaType: LOCAL_VIDEO,
            source: testVideo2
        },
        */
        {
            mediaType: YOU_TUBE_VIDEO,
            source: 'd-aNAU5cfPw',
        },
        {
            mediaType: YOU_TUBE_VIDEO,
            source: 'asqi434h8Eg',
        },
        {
            mediaType: YOU_TUBE_VIDEO,
            source: 'w_zNPScqBb8',
        },
        {
            mediaType: YOU_TUBE_VIDEO,
            source: 'PKPwV7Uu08Q',
        },
        {
            mediaType: YOU_TUBE_VIDEO,
            source: 'FpqivQ6P0s4',
        },
        {
            mediaType: YOU_TUBE_VIDEO,
            source: 'x7e2Dm5WdNg',
        },
        {
            mediaType: YOU_TUBE_VIDEO,
            source: 'c5Sy-tODTJU',
        },
        {
            mediaType: YOU_TUBE_VIDEO,
            source: 'pLYyl1ItBKE',
        },
        {
            mediaType: YOU_TUBE_VIDEO,
            source: 'ihZwWD4MFtA',
        }];
    thumbnailElements = [];


    get selectedYoutubeId(){
        return this.selectedMediaElement.mediaType === YOU_TUBE_VIDEO ? this.selectedMediaElement.source : null;
    }

    get selectedLocalVideoSource(){
        return this.selectedMediaElement.mediaType === LOCAL_VIDEO ? this.selectedMediaElement.source : null;
    }

    get selectedImageSource(){
        return this.selectedMediaElement.mediaType === IMAGE ? this.selectedMediaElement.source : null;
    }

    connectedCallback() {
        for (const mediaElement of this.mediaElements) {
            this.thumbnailElements.push(this.createMediaThumbnailElement(mediaElement));
        }
    }

    renderedCallback() {
        if (this.hasRendered === false) {
            try {
                if (screen.width <= 500) {
                    this.mediaContainerWidth = 100;
                } else {
                    this.mediaContainerWidth = 25;
                }
                let carouselContent = this.template.querySelector('.carousel-content');
                let left = -this.mediaContainerWidth;
                for (let i = 0; i < 6; i++) {
                    let mediaThumbnailContainer = document.createElement('div');
                    mediaThumbnailContainer.setAttribute("data-index", '' + i);
                    mediaThumbnailContainer.classList.add('media-thumbnail-container');
                    mediaThumbnailContainer.style.left = left + '%';
                    mediaThumbnailContainer.onclick = this.onMediaSelect.bind(this);
                    left += this.mediaContainerWidth;
                    let mediaThumbnail = this.thumbnailElements[i];
                    mediaThumbnailContainer.insertBefore(mediaThumbnail, null);
                    carouselContent.insertBefore(mediaThumbnailContainer, null);
                }
                this.selectedMediaElement = this.mediaElements[1];
                this.hasRendered = true;
            } catch (error) {
                console.error(error);
            }

            window.onresize = () => {
                let isBreakPoint = false;
                if (screen.width <= 500 && this.mediaContainerWidth !== 100) {
                    this.mediaContainerWidth = 100;
                    isBreakPoint = true;
                } else if (screen.width > 500 && this.mediaContainerWidth === 100) {
                    this.mediaContainerWidth = 25;
                    isBreakPoint = true;
                }
                if (isBreakPoint) {
                    let carouselContent = this.template.querySelector('.carousel-content');
                    let left = -this.mediaContainerWidth;
                    for (const child of carouselContent.children) {
                        child.style.left = left + '%';
                        left += this.mediaContainerWidth;
                    }
                }
            }
        }
    }

    createMediaThumbnailElement(mediaElement) {
        switch (mediaElement.mediaType) {
            case YOU_TUBE_VIDEO: {
                let mediaThumbnail = document.createElement('img');
                mediaThumbnail.src = `https://img.youtube.com/vi/${mediaElement.source}/mqdefault.jpg`;
                return mediaThumbnail;
            }
            case LOCAL_VIDEO: {
                let video = document.createElement('video');
                video.preload = "metadata";
                let source = document.createElement('source');
                source.type = 'video/mp4';
                source.src = mediaElement.source;
                video.insertBefore(source, null);
                return video;
            }
            case IMAGE: {
                let mediaThumbnail = document.createElement('img');
                mediaThumbnail.src = mediaElement.source;
                return mediaThumbnail;
            }
        }
    }

    onPrevClick(event) {
        try {
            if (screen.width <= 500) {
                this.mediaContainerWidth = 100;
            } else {
                this.mediaContainerWidth = 25;
            }
            this.startIndex--;
            if (this.startIndex < 0) {
                this.startIndex = this.mediaElements.length - 1;
            }
            let carouselContent = this.template.querySelector('.carousel-content');
            carouselContent.removeChild(carouselContent.lastElementChild);
            let left = 0;
            for (const child of carouselContent.children) {
                child.style.left = left + '%';
                left += this.mediaContainerWidth;
            }
            let mediaThumbnailContainer = document.createElement('div');
            mediaThumbnailContainer.classList.add('media-thumbnail-container');
            mediaThumbnailContainer.style.left = -this.mediaContainerWidth + '%';
            mediaThumbnailContainer.setAttribute("data-index", '' + this.startIndex);
            mediaThumbnailContainer.onclick = this.onMediaSelect.bind(this);
            let mediaThumbnail = this.thumbnailElements[this.startIndex];
            mediaThumbnailContainer.insertBefore(mediaThumbnail, null);
            carouselContent.insertBefore(mediaThumbnailContainer, carouselContent.firstElementChild);
        } catch (error) {
            console.error(error);
        }
    }

    onNextClick(event) {
        try {
            if (screen.width <= 500) {
                this.mediaContainerWidth = 100;
            } else {
                this.mediaContainerWidth = 25;
            }
            this.startIndex++;
            if (this.startIndex === this.mediaElements.length) {
                this.startIndex = 0;
            }
            let carouselContent = this.template.querySelector('.carousel-content');
            carouselContent.removeChild(carouselContent.firstElementChild);
            let left = -this.mediaContainerWidth;
            for (const child of carouselContent.children) {
                child.style.left = left + '%';
                left += this.mediaContainerWidth;
            }
            let index = this.startIndex + 5 < this.mediaElements.length ? this.startIndex + 5 : this.startIndex + 5 - this.mediaElements.length;
            let mediaThumbnailContainer = document.createElement('div');
            mediaThumbnailContainer.classList.add('media-thumbnail-container');
            mediaThumbnailContainer.style.left = left + '%';
            mediaThumbnailContainer.setAttribute("data-index", '' + index);
            mediaThumbnailContainer.onclick = this.onMediaSelect.bind(this);
            let mediaThumbnail = this.thumbnailElements[index];
            mediaThumbnailContainer.insertBefore(mediaThumbnail, null);
            carouselContent.insertBefore(mediaThumbnailContainer, null);
        } catch (error) {
            console.error(error);
        }
    }

    onMediaSelect(event) {
        try {
            let index = +event.currentTarget.dataset.index;
            this.selectedMediaElement = this.mediaElements[index];
        } catch (error) {
            console.error(error);
        }
    }
}