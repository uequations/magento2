<?php

declare(strict_types=1);

namespace Laminas\View\Renderer;

use ArrayAccess;
use Laminas\View\Exception;
use Laminas\View\Model\FeedModel;
use Laminas\View\Model\ModelInterface as Model;
use Laminas\View\Resolver\ResolverInterface as Resolver;

use function get_debug_type;
use function in_array;
use function is_string;
use function sprintf;
use function strtolower;

/**
 * Class for Laminas\View\Strategy\FeedStrategy compatible template engine implementations
 *
 * @final
 */
class FeedRenderer implements RendererInterface
{
    /** @var Resolver */
    protected $resolver;

    /** @var string 'rss' or 'atom'; defaults to 'rss' */
    protected $feedType = 'rss';

    /**
     * Return the template engine object, if any
     *
     * If using a third-party template engine, such as Smarty, patTemplate,
     * phplib, etc, return the template engine object. Useful for calling
     * methods on these objects, such as for setting filters, modifiers, etc.
     *
     * @return mixed
     */
    public function getEngine()
    {
        return $this;
    }

    /**
     * Set the resolver used to map a template name to a resource the renderer may consume.
     *
     * @todo   Determine use case for resolvers for feeds
     * @return FeedRenderer
     */
    public function setResolver(Resolver $resolver)
    {
        $this->resolver = $resolver;
        return $this;
    }

    /**
     * Renders values as JSON
     *
     * @todo   Determine what use case exists for accepting only $nameOrModel
     * @param  string|Model $nameOrModel The script/resource process, or a view model
     * @param  null|array<string, mixed>|ArrayAccess<string, mixed> $values Values to use during rendering
     * @throws Exception\InvalidArgumentException
     * @return string The script output.
     */
    public function render($nameOrModel, $values = null)
    {
        if ($nameOrModel instanceof Model) {
            // Use case 1: View Model provided
            // Non-FeedModel: cast to FeedModel
            if (! $nameOrModel instanceof FeedModel) {
                $vars    = $nameOrModel->getVariables();
                $options = $nameOrModel->getOptions();
                $type    = $this->getFeedType();
                if (isset($options['feed_type'])) {
                    $type = $options['feed_type'];
                } else {
                    $this->setFeedType($type);
                }
                $nameOrModel = new FeedModel($vars, ['feed_type' => $type]);
            }
        } elseif (is_string($nameOrModel)) {
            // Use case 2: string $nameOrModel + array|Traversable|Feed $values
            $nameOrModel = new FeedModel($values, (array) $nameOrModel);
        } else {
            // Use case 3: failure
            throw new Exception\InvalidArgumentException(sprintf(
                '%s expects a ViewModel or a string feed type as the first argument; received "%s"',
                __METHOD__,
                get_debug_type($nameOrModel),
            ));
        }

        // Get feed and type
        $feed = $nameOrModel->getFeed();
        $type = $nameOrModel->getFeedType();
        if (! is_string($type)) {
            $type = $this->getFeedType();
        } else {
            $this->setFeedType($type);
        }

        // Render feed
        return $feed->export($type);
    }

    /**
     * Set feed type ('rss' or 'atom')
     *
     * @param  string $feedType
     * @throws Exception\InvalidArgumentException
     * @return FeedRenderer
     */
    public function setFeedType($feedType)
    {
        $feedType = strtolower($feedType);
        if (! in_array($feedType, ['rss', 'atom'])) {
            throw new Exception\InvalidArgumentException(sprintf(
                '%s expects a string of either "rss" or "atom"',
                __METHOD__
            ));
        }

        $this->feedType = $feedType;
        return $this;
    }

    /**
     * Get feed type
     *
     * @return string
     */
    public function getFeedType()
    {
        return $this->feedType;
    }
}
