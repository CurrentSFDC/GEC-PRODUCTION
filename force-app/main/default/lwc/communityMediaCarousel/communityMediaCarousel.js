import {LightningElement, api, track} from 'lwc';

const YOU_TUBE_VIDEO = "Youtube Link";
const LOCAL_VIDEO = "Other Link";
const IMAGE_LINK = "Image Link";
const LOCAL_IMAGE = "Local Image";
const VIMEO_VIDEO = "Vimeo Link";

export default class CommunityMediaCarousel extends LightningElement {

    @api communityContentMedia;

    startIndex = 0;
    hasRendered = false;
    selectedMediaElement = {};
    mediaContainerWidth;
    mediaElements;
    thumbnailElements = [];
    @track videoDetails;
    @track tempDetails;
    @track tempID;
    @track vimeo;
    vimeoVideo;
    data = [];


    get showNavigator() {
        if (this.mediaElements == null) {
            return false;
        }
        if (screen.width <= 500 && this.mediaElements.length > 1) {
            return true;
        }
        if (screen.width > 500 && this.mediaElements.length >= 6) {
            return true;
        }
    }

    get selectedYoutubeId() {
        return this.selectedMediaElement != null && this.selectedMediaElement.mediaType === YOU_TUBE_VIDEO ? this.selectedMediaElement.source : null;
    }

    get selectedLocalVideoSource() {
        return this.selectedMediaElement != null && this.selectedMediaElement.mediaType === LOCAL_VIDEO ? this.selectedMediaElement.source : null;
    }

    get selectedImageSource() {
        //return this.selectedMediaElement != null && this.selectedMediaElement.mediaType === IMAGE ? '/Agents/file-asset/' + this.selectedMediaElement.source : null;
        return this.selectedMediaElement != null && this.selectedMediaElement.mediaType === IMAGE_LINK ? this.selectedMediaElement.source : null;

    }

    get selectedLocalImageSource() {
        //return this.selectedMediaElement != null && this.selectedMediaElement.mediaType === IMAGE ? '/Agents/file-asset/' + this.selectedMediaElement.source : null;
        return this.selectedMediaElement != null && this.selectedMediaElement.mediaType === LOCAL_IMAGE ? this.selectedMediaElement.source : null;

    }

    get selectedVimeoSource() {
        //return this.selectedMediaElement != null && this.selectedMediaElement.mediaType === IMAGE ? '/Agents/file-asset/' + this.selectedMediaElement.source : null;
        return this.selectedMediaElement != null && this.selectedMediaElement.mediaType === VIMEO_VIDEO ? this.selectedMediaElement.source : null;


    }

    async connectedCallback() {
        console.log('Selected Media Element: ' + this.selectedMediaElement);
        console.log(`CommunityMediaCarousel communityContentMedia`, JSON.parse(JSON.stringify(this.communityContentMedia)));
        console.log('STARTING IMAGE INDEX: ' + this.startIndex);
        this.mediaElements = [];
        for (const media of this.communityContentMedia) {
            this.mediaElements.push({
                mediaType: media.Type__c,
                source: media.Media_Id__c != null ? media.Media_Id__c : media.Content_URL__c,
                thumbnail: media.Thumbnail__c
                //source: media.URL__c
            });
        }
        console.log(`this.mediaElements`, JSON.parse(JSON.stringify(this.mediaElements)));
        for (const mediaElement of this.mediaElements) {
            this.thumbnailElements.push(this.createMediaThumbnailElement(mediaElement));

        }
        console.log(`this.thumbnailElements`, JSON.parse(JSON.stringify(this.thumbnailElements)));
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
                if (this.mediaElements.length < 6) {
                    let left = 0;
                    for (let i = 0; i < this.mediaElements.length; i++) {
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
                    this.template.querySelectorAll('.carousel-navigator').forEach(e => e.style.display = "none");
                } else {
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
                }
                this.selectedMediaElement = this.mediaElements[this.startIndex];
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
            case VIMEO_VIDEO: {
                let mediaThumbnail = document.createElement('img');
                mediaThumbnail.src = mediaElement.thumbnail;
                return mediaThumbnail;
            }
            /*case LOCAL_VIDEO: {
                let video = document.createElement('video');
                video.preload = "metadata";
                let source = document.createElement('source');
                source.type = 'video/mp4';
                source.src = mediaElement.source;
                video.insertBefore(source, null);
                return video;
            }*/
            case IMAGE_LINK: {
                let mediaThumbnail = document.createElement('img');
                //mediaThumbnail.src = '/Agents/file-asset/'+mediaElement.source;
                mediaThumbnail.src = mediaElement.source;
                return mediaThumbnail;
            }
            case LOCAL_IMAGE: {
                let mediaThumbnail = document.createElement('img');
                //mediaThumbnail.src = '/Agents/file-asset/'+mediaElement.source;
                mediaThumbnail.src = mediaElement.source;
                return mediaThumbnail;
            }
        }
    }

    async getDetails(tempDetails) {


        return new Promise((resolve, reject) => {
            fetch(tempDetails)
                .then(response => {
                    return response.json();
                })
                .then(result => {
                    resolve(result);
                })
                .catch(error => {
                    reject(error);
                });
        });


        /*const response = await fetch(tempDetails);

        var data = await response.json();

         console.log('Data from API: '+data);

         let decoded = JSON.stringify(data);
         console.log('Video Details: '+decoded);

         let decodedParsed = JSON.parse(decoded);


         var thumbnail = decodedParsed[0];
         console.log('Image: '+thumbnail.thumbnail_small);


         this.videoDetails = thumbnail.thumbnail_small;
         console.log('this.videoDetails: '+this.videoDetails);*/
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
            console.log('Selected Index: ' + index);
            this.selectedMediaElement = this.mediaElements[index];
        } catch (error) {
            console.error(error);
        }
    }
}